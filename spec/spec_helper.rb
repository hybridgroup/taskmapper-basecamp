require 'taskmapper-basecamp'
require 'rspec'
require 'fakeweb'

FakeWeb.allow_net_connect = false

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

def fixture_file(filename)
  return '' if filename == ''
  path = File.expand_path("#{File.dirname(__FILE__)}/fixtures/#{filename}")
  File.read path
end

def stub_request(method, url, filename, status = nil, content_type = 'application/xml')
  options = {:body => ""}
  options.merge!({:body => fixture_file(filename)}) if filename
  options.merge!({:body => status.last}) if status.is_a?(Array)
  options.merge!({:status => status}) if status
  options.merge!({:content_type => content_type})

  FakeWeb.register_uri method, url, options
end

def stub_get(*args) ; stub_request(:get, *args) end
def stub_post(*args); stub_request(:post, *args) end
def stub_put(*args); stub_request(:put, *args) end
def stub_delete(*args); stub_request(:delete, *args) end

def base_uri
  "https://000000:Basecamp@#{domain}"
end

RSpec.configure do |c|
  c.before do
    stub_get "#{base_uri}/people/me.xml", 'project_count.xml'
    stub_get "#{base_uri}/projects.xml", "projects.xml"
    stub_get "#{base_uri}/projects/5220065.xml", "projects/5220065.xml"
    stub_get "#{base_uri}/projects/5220065/todo_lists.xml?responsible_party=", 'todo_list_with_items.xml'
    stub_get "#{base_uri}/todo_items/133184178.xml", 'todo_item.xml'
    stub_put "#{base_uri}/todo_items/133184178.xml", 'todo_item.xml'
    stub_get "#{base_uri}/todo_items/133184178/comments.xml", 'comments.xml'
    stub_get "#{base_uri}/todo_items/133184178/comments/74197051.xml", 'comments/74197051.xml'
    stub_get "#{base_uri}/todo_items/133184178/comments/74197096.xml", 'comments/74197096.xml'
    stub_get "#{base_uri}/todo_lists/19700377/todo_items.xml", 'todo_list_with_items.xml'
    stub_get "#{base_uri}/todo_lists/19700382/todo_items.xml", 'todo_list_with_items.xml'
    stub_get "#{base_uri}/todo_lists/19700819/todo_items.xml", 'todo_list_with_items.xml'
    stub_post "#{base_uri}/projects.xml", ''
    stub_post "#{base_uri}/projects/5220065/todo_lists.xml", ''
    stub_post "#{base_uri}/todo_lists/9972756/todo_items.xml", ''
  end
end
