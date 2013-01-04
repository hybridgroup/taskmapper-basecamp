$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'taskmapper'
require 'active_resource/http_mock'
require 'taskmapper-basecamp'
require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = 'documentation'
end

def fixture_for(name, format = 'xml')
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}.#{format}")
end
