require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Basecamp::Ticket" do
  let(:project_id) { 5220065 }
  before(:all) do
    @headers = {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'}
    @wheaders = @headers.merge('Content-Type' => 'application/xml')
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects/5220065.xml', @headers, fixture_for('projects/5220065'), 200
    end
    @project = tm.project(project_id)
  end
  let(:ticket_id) { 133184178 }
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
      it { subject.first.id.should be_eql(ticket_id) }
    end

    context "when #tickets is call to a project instance with attributes" do 
      subject { @project.tickets(:id => ticket_id) }
      it { should be_an_instance_of(Array) }
      it { subject.first.should be_an_instance_of(ticket_class) }
      it { subject.first.id.should be_eql(ticket_id) }
    end
  end

  describe "Retrieve a single ticket" do 
    context "when #ticket is call to a project instance with an ticket id" do 
      subject { @project.ticket(ticket_id) }
      it { should be_an_instance_of(ticket_class) }
      it { subject.id.should be_eql(ticket_id) } 
    end

    context "when #ticket is call to a project instance with ticket attributes" do 
      subject { @project.ticket(:id => ticket_id) }
      it { should be_an_instance_of(ticket_class) }
      it { subject.id.should be_eql(ticket_id) }
    end
  end

  describe "Update and creation" do 
    before(:all) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post '/todo_lists/9972756/todo_items.xml', @wheaders, '', 200
        mock.post '/projects/5220065/todo_lists.xml', @wheaders, '', 200
      end
    end

    context "when an instance of ticket is changed and then called the save method" do 
      subject { @project.ticket(ticket_id) } 
      pending { subject.save.should be_false }
    end

    context "when #ticket! method is call to a project instance" do 
      subject { @project.ticket!(:todo_list_id => 9972756, :title => 'Ticket #12', :description => 'Body') }
      it { should be_an_instance_of(ticket_class) } 
      it { subject.project_id.should_not be_nil }
      it { subject.todo_list_id.should_not be_nil }
    end

    context "when #ticket! method is call without a todo_list_id" do 
      subject { @project.ticket!(:title => 'Ticket #13', :description => 'Body') }
      pending { should be_an_instance_of(ticket_class) }
      pending { subject.project_id.should_not be_nil }
      pending { subject.todo_list_id.should_not be_nil }
    end
  end

end
