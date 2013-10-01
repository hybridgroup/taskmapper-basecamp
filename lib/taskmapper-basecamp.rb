require 'taskmapper'
require 'basecamp'
require 'active_support/all'

module HTMLStripper
  def remove_tags
    self.empty? ? "" : self.gsub(/(<[^>]*>)|\n|\t/s) {""}
  end
end

class Hash
  class << self
    alias_method :from_xml_original, :from_xml

    def from_xml(xml)
      scrubbed = scrub_attributes(xml)
      from_xml_original(scrubbed)
    end

    def scrub_attributes(xml)
      xml.gsub(/<comments type=\"array\" count=\"*\">/, "<stories type=\"array\">")
    end
  end
end

require 'provider/basecamp'
require 'provider/project'
require 'provider/ticket'
require 'provider/comment'
