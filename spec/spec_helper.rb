$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'taskmapper'
require 'active_resource/http_mock'
require 'taskmapper-basecamp'
require 'rspec'

def fixture_for(name, format = 'xml')
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}.#{format}")
end
