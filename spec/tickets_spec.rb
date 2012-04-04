require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Basecamp::Ticket" do
  before(:all) do
    headers = {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    wheaders = headers.merge('Content-Type' => 'application/xml')
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects/5220065.xml', headers, fixture_for('projects/5220065'), 200
      mock.get '/projects/5220065/todo_lists.xml', headers, fixture_for('todo_lists'), 200
      mock.get '/todo_lists/9973518/todo_items.xml', headers, fixture_for('todo_lists/9973518_items'), 200
      mock.get '/todo_lists/9972756/todo_items.xml', headers, fixture_for('todo_lists/9972756_items'), 200
      mock.put '/todo_items/62509330.xml', wheaders, '', 200
      mock.post '/todo_lists/9972756/todo_items.xml', wheaders, '', 200
    end
    @project_id = 5220065
    @ticket_id = 62509330
  end

  before(:each) do
    @ticketmaster = TicketMaster.new(:basecamp, :domain => 'ticketmaster.basecamphq.com', :token => '000000')
    @project = @ticketmaster.project(@project_id)
    @klass = TicketMaster::Provider::Basecamp::Ticket
  end

  it "should be able to load all tickets" do
    @project.tickets.should be_an_instance_of(Array)
    @project.tickets.first.should be_an_instance_of(@klass)
  end

  it "should be able to load all tickets based on an array of ids" do
    @tickets = @project.tickets([@ticket_id])
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.id.should == @ticket_id
  end

  it "should be able to load all tickets based on attributes" do
    @tickets = @project.tickets(:id => @ticket_id)
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.id.should == @ticket_id
  end

  it "should return the ticket class" do
    @project.ticket.should == @klass
  end

  it "should be able to load a single ticket" do
    @ticket = @project.ticket(@ticket_id)
    @ticket.should be_an_instance_of(@klass)
    @ticket.id.should == @ticket_id
  end

  it "should be able to load a single ticket based on attributes" do
    @ticket = @project.ticket(:id => @ticket_id)
    @ticket.should be_an_instance_of(@klass)
    @ticket.id.should == @ticket_id
  end

  it "should be able to update and save a ticket" do
    @ticket = @project.ticket(@ticket_id)
    @ticket.save.should == nil
    @ticket.description = 'hello'
    @ticket.save.should == true
  end

  it "should be able to create a ticket" do
    @ticket = @project.ticket!(:todo_list_id => 9972756, :title => 'Ticket #12', :description => 'Body')
    @ticket.should be_an_instance_of(@klass)
  end

end
