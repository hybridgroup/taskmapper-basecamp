require 'spec_helper'

describe TaskMapper::Provider::Basecamp::Ticket do
  let(:project_id) { 5220065 }
  let(:project) { tm.project(project_id) }
  let(:tm) { create_instance }
  let(:ticket_class) { TaskMapper::Provider::Basecamp::Ticket }

  context "Retrieve tickets" do
    shared_examples_for "ticket 19700819" do
      its(:id) { should ==  19700819 }
      its(:priority) { should == 1 }
      its(:status) { should == "incomplete" }
      its(:resolution) { should == "In Progress" }
      its(:updated_at) { should be_an_instance_of Time }
      its(:assignee) { should == "Unassigned" }
      its(:project_id) { should == 5220065 }
    end

    describe "Reatrieve all" do
      let(:tickets) { project.tickets }
      subject { tickets }

      its(:count) { should == 4 }

      describe :first do
        subject { tickets.first }
        it_should_behave_like "ticket 19700819"
      end
    end

    describe "Search passing ids array'" do
      let(:tickets) { project.tickets [19700819, 19700382] }
      subject { tickets }

      its(:count) { should == 2 }

      describe :first do
        subject { tickets.first }
        it_should_behave_like "ticket 19700819"
      end
    end

    describe "Find by id" do
      subject { project.ticket 19700819 }
      it_should_behave_like "ticket 19700819"
    end
  end

  pending "Update and creation" do
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
