class Photo < PostType
  fields :photo_url, :caption, :url
  required :photo_url
  primary :caption
  
  # special :photo_url do |photo_url_content|
  #   if photo_url_content.blank? && !blank_attr?(:caption)
  #     possible_url = get_attr(:caption).match(/^(http:\/\/.+)\n/)
  #     unless possible_url.blank?
  #       possible_url = possible_url.captures.first
  #       if %w(jpg gif png).include?(possible_url[-3..-1])
  #         set_attr :photo_url, possible_url
  #       end#if
  #     end#unless
  #   end#if
  # end#special
  
  special :url do |link_content|
    'http://' + link_content.gsub(/^http:\/\//, '')
  end
  
  html do
    haml %Q{
      %p
        - if get_attr?(:url)
          %a{:href=>get_attr(:url)}
            %img{:src=>get_attr(:photo_url)}
        - else
          %img{:src=>get_attr(:photo_url)}

      ~ get_attr(:caption)
    }.indents(true)
  end
  
  def self.detect?(text)
    has_required? text
  end
end