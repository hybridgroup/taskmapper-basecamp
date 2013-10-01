require 'spec_helper'

describe TaskMapper::Provider::Basecamp::Comment do
  let(:project_id) { 5220065 }
  let(:ticket_id) { 19700819 }
  let(:tm) { TaskMapper.new(:basecamp, :domain => 'ticketmaster.basecamphq.com', :token => '000000') }
  let(:comment_class) { TaskMapper::Provider::Basecamp::Comment }
  let(:comment_id) { 74197051 }
  let(:headers) { {'Authorization' => 'Basic MDAwMDAwOkJhc2VjYW1w'} }
  let(:nheaders) { headers.merge('Accept' => 'application/xml') }
  let(:pheaders) { headers.merge('Content-Type'=>'application/xml') }
  let(:project) { tm.project(project_id) }
  let(:ticket) { project.ticket(ticket_id) }

  context "Retrieve comments" do
    before(:each) do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/projects/#{project_id}.xml", nheaders, fixture_for('projects/5220065'), 200
        mock.get "/projects/#{project_id}/todo_lists.xml?responsible_party=", nheaders, fixture_for('todo_list_with_items'), 200
        mock.get "/todo_lists/19700819/todo_items.xml", nheaders, fixture_for('todo_list_with_items'), 200
        mock.get "/todo_lists/19700382/todo_items.xml", nheaders, fixture_for('todo_list_with_items'), 200
        mock.get "/todo_lists/19700377/todo_items.xml", nheaders, fixture_for('todo_list_with_items'), 200

        mock.get "/todo_items/19700819/comments.xml", nheaders, fixture_for('comments'), 200
        mock.get "/todo_items/19700819/comments/74197051.xml", nheaders, fixture_for('comments/74197051'), 200
        mock.get "/todo_items/19700819/comments/74197096.xml", nheaders, fixture_for('comments/74197051'), 200
      end
    end

    shared_examples_for "comment 74197051" do
      its(:id) { should == 74197051 }
      its(:body) { should == "<div>Hello There<br /></div>" }
      its(:created_at) { should be_an_instance_of Time }
    end

    describe "Retrieve all" do
      let(:comments) { ticket.comments }
      subject { comments }
      its(:count) { should == 4 }

      describe :first do
        subject { comments.first }
        it_should_behave_like "comment 74197051"
      end
    end

    describe "Search passing ids array" do
      let(:comments) { ticket.comments [74197051, 74197096] }
      subject { comments }

      its(:count) { should == 2 }

      describe :first do
        subject { comments.first }
        it_should_behave_like "comment 74197051"
      end
    end

    describe "Find by id" do
      subject { ticket.comment 74197051 }
      it_should_behave_like  "comment 74197051"
    end
  end

  pending "Create and update a comment for a ticket" do
    context "when a comment is changed and then called the #save on it" do
      it do
        comment = ticket.comment(comment_id)
        comment.body = "updated comment"
        comment.save.should be_true
        comment.body.should be_eql("updated comment")
      end
    end

    context "when #comment! is call" do
      subject { ticket.comment!(:body => 'hello there boys and girls') }
      it { should be_an_instance_of(comment_class) }
      it { subject.body.should_not be_nil }
      it { subject.id.should_not be_nil }
      it { subject.ticket_id.should_not be_nil }
    end
  end
end
