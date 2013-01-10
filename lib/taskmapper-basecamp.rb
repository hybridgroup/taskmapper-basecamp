require 'basecamp'
require 'active_support/all'

module HTMLStripper 
  def remove_tags
    self.empty? ? "" : self.gsub(/(<[^>]*>)|\n|\t/s) {""} 
  end
end

%w{ basecamp ticket project comment }.each do |f|
  require File.dirname(__FILE__) + '/provider/' + f + '.rb';
end
