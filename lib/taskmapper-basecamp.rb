require 'active_support/all'
require File.dirname(__FILE__) + '/basecamp/basecamp.rb'

%w{ basecamp ticket project comment }.each do |f|
  require File.dirname(__FILE__) + '/provider/' + f + '.rb';
end
