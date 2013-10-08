require 'taskmapper-basecamp'
require 'rspec'
require 'active_resource/http_mock'

def token
  '000000'
end

def domain
  'ticketmaster.basecamphq.com'
end

def create_instance(t = token, d = domain)
  TaskMapper.new(
    :basecamp,
    :token => '000000',
    :domain => 'ticketmaster.basecamphq.com'
  )
end

def fixture_for(filename, format = "xml")
  return '' if filename == ''
  path = "#{File.dirname(__FILE__)}/fixtures/#{filename}.#{format}"
  File.read File.expand_path(path)
end

def headers
  {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
end

def rheaders
  headers.merge('Accept' => 'application/xml')
end

def pheaders
  headers.merge('Content-Type'=>'application/xml')
end
