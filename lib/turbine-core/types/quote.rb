class Quote < PostType
  fields :quote, :source
  required :quote
  primary :quote
  
  special :quote do |quote_content|
    unless (quote_content =~ /^<blockquote/).nil?
      doc = Nokogiri::HTML(quote_content)
      doc.css('blockquote').each { |q| quote_content = q.content }
    else
      quote_content = ''
    end
    quote_content.strip
  end
  
  html do
    haml %Q{
      - unless blank_attr?(:source)
        %p
          Source:
          = get_attr(:source)

      %blockquote~ get_attr(:quote)
    }.indents(true)
  end
  
  def self.detect?(text)
    pairs = get_pairs(text)
    
    the_quote = pairs.select { |pair| pair.keys.first == :quote }
    the_quote = the_quote.first || {}
    
    markdown = Markdown.new(the_quote[:quote])
    quote_html = markdown.text.blank? ? "" : markdown.to_html.strip
    
    !(text =~ /Quote: (.*)/).nil? || !(quote_html =~ /^<blockquote(.+)<\/blockquote>$/m).nil?
  end
end