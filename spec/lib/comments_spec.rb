require 'spec_helper'

describe TaskMapper::Provider::Basecamp::Comment do
  let(:project_id) { 5220065 }
  let(:ticket_id) { 19700819 }
  let(:tm) { create_instance }
  let(:comment_class) { TaskMapper::Provider::Basecamp::Comment }
  let(:comment_id) { 74197051 }
  let(:project) { tm.project(project_id) }
  let(:ticket) { project.ticket(ticket_id) }

  context "Retrieve comments" do
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
