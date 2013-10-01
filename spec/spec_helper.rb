require 'taskmapper-basecamp'
require 'rspec'
require 'active_resource/http_mock'

def fixture_for(name, format = 'xml')
  File.read(File.dirname(__FILE__) + "/fixtures/#{name}.#{format}")
end
