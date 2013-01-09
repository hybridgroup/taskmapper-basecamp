require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TaskMapper::Provider::Basecamp::Ticket do
  let(:project_id) { 5220065 }
  let(:headers) { {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'} }
  let(:nheaders) { headers.merge('Accept' => 'application/xml') }
  let(:wheaders) { headers.merge('Content-Type' => 'application/xml') }
  let(:project) { tm.project(project_id) }
  let(:tm) { TaskMapper.new(:basecamp, :domain => 'ticketmaster.basecamphq.com', :token => '000000') }
  let(:ticket_class) { TaskMapper::Provider::Basecamp::Ticket }

  context "Retrieve tickets" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/projects/#{project_id}.xml", nheaders, fixture_for('projects/5220065'), 200
        mock.get "/projects/#{project_id}/todo_lists.xml?responsible_party=", nheaders, fixture_for('todo_list_with_items'), 200
        mock.get "/todo_lists/19700819/todo_items.xml", nheaders, fixture_for('todo_list_with_items'), 200
        mock.get "/todo_lists/19700382/todo_items.xml", nheaders, fixture_for('todo_list_with_items'), 200
        mock.get "/todo_lists/19700377/todo_items.xml", nheaders, fixture_for('todo_list_with_items'), 200
      end
    end

    shared_examples_for "ticket 133184178" do
      its(:title) { should match /updated/ }
      its(:priority) { should == 1 }
      its(:status) { should == 'incomplete' }
      its(:resolution) { should == 'In Progress' }
      its(:updated_at) { should be_an_instance_of Time }
      its(:description) { should match /updated/ }
      its(:assignee) { should == 'Unassigned' }
      its(:requestor) { should match /Clutch/ }
      its(:project_id) { should == 5220065 }
    end

    describe "Reatrieve all" do 
      let(:tickets) { project.tickets }
      subject { tickets }

      its(:count) { should == 4 }

      describe :first do 
        subject { tickets.first }
        its(:id) { should ==  19700819 }
      end
    end

    pending "Search passing ids array'" do
      let(:tickets) { project.tickets [133184178, 19700382] }
      subject { tickets }

      its(:count) { should == 2 }

      describe :first do 
        subject { tickets.first }
      end
    end

    describe "Find by id" do 
      subject { project.ticket 133184178 }
    end
  end

  pending "Update and creation" do 
    before(:all) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post '/todo_lists/9972756/todo_items.xml', wheaders, '', 200
        mock.post '/projects/5220065/todo_lists.xml', wheaders, '', 200
      end
    end

    context "when an instance of ticket is changed and then called the save method" do 
      subject { project.ticket(133184178) } 
      pending { subject.save.should be_false }
    end

    context "when #ticket! method is call to a project instance" do 
      subject { project.ticket!(:todo_list_id => 9972756, :title => 'Ticket #12', :description => 'Body') }
      it { should be_an_instance_of(ticket_class) } 
      it { subject.project_id.should_not be_nil }
      it { subject.todo_list_id.should_not be_nil }
    end

    context "when #ticket! method is call without a todo_list_id" do 
      subject { project.ticket!(:title => 'Ticket #13', :description => 'Body') }
      pending { should be_an_instance_of(ticket_class) }
      pending { subject.project_id.should_not be_nil }
      pending { subject.todo_list_id.should_not be_nil }
    end
  end

end
