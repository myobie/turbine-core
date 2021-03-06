require 'rdiscount' # markdown
require 'nokogiri'
require 'uuidtools'
require 'haml'

class PostType
  extend ClassLevelInheritableAttributes
  include Extlib::Hook
  
  DEFAULT_FIELDS = [:published_at, :status, :slug, :trackbacks, :type, :tags]
  NON_EDITABLE_FIELDS = [:trackbacks, :type, :published_at]
  
  
  # vars to inherit down
  cattr_inheritable :fields_list, :allowed_fields_list, :required_fields_list, :primary_field, :heading_field, 
                    :specials_blocks, :defaults_blocks, :string_for_blocks, :only_declared_fields, :always_use_uuid,
                    :truncate_slugs, :markdown_fields, :html_block
  
  # defaults for class instance inheritable vars
  @fields_list = []
  @allowed_fields_list = DEFAULT_FIELDS
  @required_fields_list = []
  @primary_field = nil
  @heading_field = nil
  @specials_blocks = {}
  @defaults_blocks = {}
  @string_for_blocks = {}
  @only_declared_fields = true
  @always_use_uuid = false
  @truncate_slugs = true
  @markdown_fields = []
  @html_block = nil
  
  ### cattr_accessor
  @@preferred_order = []
  
  def self.preferred_order
    @@preferred_order
  end
  def self.preferred_order=(new_order)
    @@preferred_order = new_order
  end
  ### cattr_accessor
  
  ### Defaults
  after_class_method :inherited do |all_children, klass|
    klass.string_for :tags do |tags_array|
      tags_array.join(', ')
    end
    
    klass.special :tags do |tags_string|
      if tags_string.is_a? String
        tags_string.split(',').collect { |t| t.strip }
      else
        tags_string
      end
    end
    
    klass.default :slug do
      generate_slug
    end
    
    all_children #return original result
  end
  
  attr_accessor :content # where everything is stored
  
  ### basic setup methods for types of posts
  def self.fields(*list)
    self.fields_list = list.make_attrs
    self.allowed_fields_list = [DEFAULT_FIELDS, list.make_attrs].flatten.uniq
  end
  
  def self.allow(*list)
    self.allowed_fields_list = [self.allowed_fields_list, list.make_attrs].flatten.uniq
  end
  
  def self.required(*list)
    self.required_fields_list = [
                                  self.required_fields_list,
                                  list.make_attrs.reject { |l| !fields_list.include? l }
                                ].flatten.uniq
  end
  
  def self.primary(field)
    field = field.make_attr
    
    if fields_list.include? field
      self.primary_field = field
      markdown field # primary is a markdown field by default
    end
  end
  
  def self.heading(field)
    field = field.make_attr
    self.heading_field = field if fields_list.include? field
  end
  
  def self.special(field, &block)
    field = field.make_attr
    self.specials_blocks[field] = block if allowed_fields_list.include? field
  end
  
  def self.string_for(field, &block)
    field = field.make_attr
    self.string_for_blocks[field] = block if allowed_fields_list.include? field
  end
  
  ### Defaults
  string_for :tags do |content|
    content.join(', ')
  end
  
  def self.default(field, &block)
    field = field.make_attr
    self.defaults_blocks[field] = block if allowed_fields_list.include? field
  end
  
  def self.html(&block)
    self.html_block = block
  end
  
  def self.dynamic(field, &block)
    field = field.make_attr
    self.dynamic_blocks[field] = block
    allow(field)
  end
  
  def self.markdown(*list)
    self.markdown_fields =  [
                              self.markdown_fields,
                              list.make_attrs.reject { |l| !fields_list.include? l }
                            ].flatten.uniq
                            
    self.allowed_fields_list = [
                                  self.allowed_fields_list, 
                                  self.markdown_fields.collect { |m| m.html }
                                ].flatten.uniq
  end
  
  # TODO: when setting an attr, we should also run it's special block if it has one
  def set_attr(key, value)
    key = key.make_attr
    
    unless value.blank?
      # run specials if there is one, or just set the key
      if self.class.specials_blocks[key]
        @content[key] = self.class.specials_blocks[key].call(value)
      else
        @content[key] = value
      end
      
      # run markdowns if there is one
      if self.class.markdown_fields.include?(key)
        markdown = Markdown.new @content[key].strip
        @content[key.html] = markdown.to_html.strip
      else
        @content.delete(key.html)
      end
    else
      # remove any blank valued keys
      @content.delete(key)
      @content.delete(key.html)
    end
  end
  
  def set_default(key, value)
    set_attr(key, value) if blank_attr?(key)
  end
  
  def blank_attr?(key)
    get_attr(key).blank?
  end
  
  def get_attr?(key)
    !blank_attr?(key)
  end
  
  # TODO: get_attr should return a default if it's blank
  def get_attr(key, html = true)
    key = key.make_attr
    
    if html && self.class.markdown_fields.include?(key)
      @content[key.html]
    else
      @content[key]
    end
  end
  
  def delete_attr(key)
    set_attr(key.make_attr, nil)
  end
  
  alias :remove_attr :delete_attr
  alias :del_attr :delete_attr
  
  # can be overriden to provide auto detection of type from a block of text
  #
  # Examples:
  #   def self.detect?(text)
  #     has_keys? text, :title, :body
  #   end
  #
  #   def self.detect?(text)
  #     has_required? text
  #   end
  #
  #   def self.detect?(text)
  #     has_one_or_more? text, :me
  #   end
  #
  def self.detect?(text)
    false
  end
  
  # useful for detection
  def self.has_keys?(text, *fields)
    needed = fields.make_attrs
    get_pairs_count(text, needed).length == needed.length
  end
  
  def self.has_more_than_one?(text, field)
    has_more_than? text, field, 1
  end
  
  def self.has_one_or_more?(text, field)
    has_more_than? text, field, 0
  end
  
  def self.has_more_than?(text, field, amount)
    get_pairs_count(text, [field]).length > amount
  end
  
  def self.get_pairs(text)
    StringImporter.new(self).import(text)
  end
  
  def self.get_pairs_count(text, fields)
    pairs = get_pairs(text)
    pairs.reject { |pair| !fields.include?(pair.keys.first) }
  end
  
  def self.has_required?(text)
    has_keys? text, *self.required_fields_list
  end
  
  # runs through the list of children looking for one that will work
  def self.auto_detect(text)
    list = self.preferred_order.blank? ? @all_children : self.preferred_order
    
    list.each { |l| return l.new(text) if l.detect?(text) }
  end
  
  def content=(stuff) # !> method redefined; discarding old content=
    @content = { :type => self.class.name.to_s }
    import(stuff)
    @content
  end#of content=
  
  def valid? # TODO: this doesn't work if there are no required fields and the slug is not unique
    v = true
    
    if self.class.required_fields_list.blank?
      v = false unless self.class.required_fields_list.reject { |item| !get_attr(item).blank? }.blank?
    end
    
    v = false unless slug_is_unique
    
    v
  end
  
  def initialize(stuff = nil)
    if stuff
      self.content = stuff
      # sanitize_content_fields
    end
  end
  
  def save
    if valid?
      truncate_slug if self.class.truncate_slugs
      fill_default_fields
      send_to_storage
    else
      false
    end
  end
  
  def import(stuff)
    importer = Kernel.const_get(stuff.class.name+'Importer').new(self.class)
    
    # The result sent back by an importer is either:
    #   Array:
    #     [{ :one => 'stuff' }, { :two => 'stuff' }]
    #   Hash:
    #     { :one => 'stuff', :two => 'stuff' }
    result = stuff.blank? ? {} : importer.import(stuff)
    
    case result
    when Array
      commit_array(result)
    when Hash
      commit_hash(result)
    end
  end
  
  def commit_hash(pairs_hash)
    pairs_hash.each do |key, value|
      set_attr(key, value)
    end
  end
  
  def commit_array(pairs_array)
    pairs_array.each do |pairs_hash|
      commit_hash(pairs_hash)
    end
  end

  def eval_defaults
    if valid?
      self.class.defaults_blocks.each do |key, block|
        set_default(key, self.instance_eval(&block))
      end
    end
  end
  
  def get_string_for key
    if self.class.string_for_blocks[key]
      self.class.string_for_blocks[key].call(get_attr(key))
    else
      get_attr(key)
    end
  end

  def sanitize_content_fields
    @content.reject! { |key, value| !self.class.allowed_fields_list.include?(key) }
  end

  def send_to_storage # send to the db or whatever
    false
  end

  def slug_is_unique # validate uniqueness
    true
  end

  def fill_default_fields
    set_default(:published_at, Time.now.utc)
    set_default(:status, default_status)
    eval_defaults
  end

  def generate_slug # OPTIMIZE: this slug generation is ugly
    result = ''
  
    unless self.class.always_use_uuid
      result = get_attr(self.class.heading_field, false).to_s.dup unless self.class.heading_field.blank?
  
      if result.blank?
        result = get_attr(self.class.primary_field, false).to_s.dup unless self.class.primary_field.blank?
      end
  
      if result.blank?
        self.class.required_fields_list.each do |required_field|
          unless get_attr(required_field).blank?
            result = get_attr(required_field).to_s.dup
            break
          end#of unless
        end#of each
      end#of if
  
      result.slugify!
    end#of unless
  
    if result.blank? || !slug_is_unique
      result = uuid
    end
  
    result
  end

  def truncate_slug(letter_count = 50)
    unless get_attr(:slug).blank?
      new_slug = get_attr(:slug).gsub(/^(.{#{letter_count}})(.*)/) { $1.slugify }
      set_attr(:slug, new_slug)
    end
  end

  def default_status
    :published
  end

  def post_to_trackbacks
    false
  end

  def uuid
    UUID.timestamp_create.to_s
  end
  
  def to_s
    fields_to_parse = self.class.fields_list - [self.class.primary_field] + DEFAULT_FIELDS - NON_EDITABLE_FIELDS
    
    result = fields_to_parse.map do |field|
      unless blank_attr?(field)
        "#{field}: #{get_string_for(field)}" 
      end#unless
    end.compact.join("\n")
    
    unless self.class.primary_field.blank? || blank_attr?(self.class.primary_field)
      result << "\n\n" + get_attr(self.class.primary_field, false)
    end
    
    result.strip
  end
  
  def haml(data, options = {}, locals = {})
    ::Haml::Engine.new(data, options).render(self, locals)
  end
  
  def to_html
    unless self.class.html_block.blank?
      self.instance_eval(&self.class.html_block)
    else
      Markdown.new(to_s).to_html
    end
  end
  
end