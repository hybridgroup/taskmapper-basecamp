require 'spec_helper'

describe TaskMapper::Provider::Basecamp::Ticket do
  let(:project_id) { 5220065 }
  let(:ticket_id) { 133184178 }
  let(:comment_id) { 74197051 }
  let(:tm) { create_instance }
  let(:project) { tm.project project_id }
  let(:ticket) { project.ticket ticket_id }
  let(:comment_class) { TaskMapper::Provider::Basecamp::Comment }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/projects/#{project_id}.xml", rheaders, fixture_for('projects/5220065'), 200
      mock.get "/projects/#{project_id}/todo_lists.xml?responsible_party=", rheaders, fixture_for('todo_list_with_items'), 200
      mock.get "/todo_items/#{ticket_id}/comments.xml", rheaders, fixture_for('comments'), 200
      mock.get "/todo_items/#{ticket_id}/comments/74197051.xml", rheaders, fixture_for('comments/74197051'), 200
      mock.get "/todo_items/#{ticket_id}/comments/74197096.xml", rheaders, fixture_for('comments/74197051'), 200
      mock.get "/todo_lists/19700377/todo_items.xml", rheaders, fixture_for('todo_list_with_items'), 200
      mock.get "/todo_lists/19700382/todo_items.xml", rheaders, fixture_for('todo_list_with_items'), 200
      mock.get "/todo_lists/19700819/todo_items.xml", rheaders, fixture_for('todo_list_with_items'), 200
      mock.post "/todo_items/133184178/comments.xml", pheaders, fixture_for('comments/new_comment'), 200
    end
  end

  describe "#comments" do
    context "without arguments" do
      let(:comments) { ticket.comments }

      it "returns an array of all comments" do
        expect(comments).to be_an Array
        expect(comments.first).to be_a comment_class
      end
    end

    context "with an array of comment IDs" do
      let(:comments) { ticket.comments [comment_id] }

      it "returns an array of matching comments" do
        expect(comments).to be_an Array
        expect(comments.first).to be_a comment_class
        expect(comments.first.id).to eq comment_id
      end
    end

    context "with a hash containing a comment ID" do
      let(:comments) { ticket.comments :id => comment_id }

      it "returns an array containing the matching comment" do
        expect(comments).to be_an Array
        expect(comments.first).to be_a comment_class
        expect(comments.first.id).to eq comment_id
      end
    end
  end

  describe "#comment" do
    context "with a comment ID" do
      let(:comment) { ticket.comment comment_id}

      it "returns the matching comment" do
        expect(comment).to be_a comment_class
        expect(comment.id).to eq comment_id
      end
    end
  end

  describe "#comment!" do
    context "with a comment body" do
      let(:comment) { ticket.comment! :body => "New Comment" }

      it "creates a new comment" do
        expect(comment).to be_a comment_class
        expect(comment.body).to eq "New Comment"
      end
    end
  end
end
