class Photo < PostType
  fields :photo_url, :caption
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
  
  def self.detect?(text)
    has_required? text
  end
end