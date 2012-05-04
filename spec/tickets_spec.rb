require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Basecamp::Ticket" do
  before(:each) do
    @headers = {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    @wheaders = @headers.merge('Content-Type' => 'application/xml')
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects/5220065.xml', @headers, fixture_for('projects/5220065'), 200
    end
    @project = tm.project(project_id)
  end
  let(:project_id) { 5220065 }
  let(:ticket_id) { 62509330 }
  let(:tm) { TicketMaster.new(:basecamp, :domain => 'ticketmaster.basecamphq.com', :token => '000000') }
  let(:ticket_class) { TicketMaster::Provider::Basecamp::Ticket }

  describe "Retrieve tickets" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/todo_lists.xml?responsible_party=', @headers, fixture_for('todo_list_with_items'), 200
      end
    end

    context "when #tickets is call for a project instance" do 
      subject { @project.tickets }
      it { should be_an_instance_of(Array) }
      it { subject.first.should be_an_instance_of(ticket_class) }
    end

    context "when #tickets is call to a project instance with an array of id's" do 
      subject { @project.tickets([ticket_id]) }
      it { should be_an_instance_of(Array) } 
      it { subject.first.should be_an_instance_of(ticket_class) }
      it { subject.id.should be_eql(ticket_id) }
    end
  end

  it "should be able to load all tickets based on an array of ids" do
    pending
    @tickets = @project.tickets([@ticket_id])
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.id.should == @ticket_id
  end

  it "should be able to load all tickets based on attributes" do
    pending
    @tickets = @project.tickets(:id => @ticket_id)
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.id.should == @ticket_id
  end

  it "should return the ticket class" do
    pending
    @project.ticket.should == @klass
  end

  it "should be able to load a single ticket" do
    pending
    @ticket = @project.ticket(@ticket_id)
    @ticket.should be_an_instance_of(@klass)
    @ticket.id.should == @ticket_id
  end

  it "should be able to load a single ticket based on attributes" do
    pending
    @ticket = @project.ticket(:id => @ticket_id)
    @ticket.should be_an_instance_of(@klass)
    @ticket.id.should == @ticket_id
  end

  it "should be able to update and save a ticket" do
    pending
    @ticket = @project.ticket(@ticket_id)
    @ticket.save.should be_true
  end

  it "should be able to create a ticket" do
    pending
    @ticket = @project.ticket!(:todo_list_id => 9972756, :title => 'Ticket #12', :description => 'Body')
    @ticket.should be_an_instance_of(@klass)
    @ticket.project_id.should_not be_nil
    @ticket.todo_list_id.should_not be_nil
  end

  it "should be able to create a ticket without passing a todo list id" do
    pending
    @ticket = @project.ticket!(:title => 'Ticket #13', :description => 'Body')
    @ticket.should be_an_instance_of(@klass)
    @ticket.project_id.should_not be_nil
    @ticket.todo_list_id.should_not be_nil
  end

end
