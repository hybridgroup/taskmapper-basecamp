require 'spec_helper'

describe TaskMapper::Provider::Basecamp::Ticket do
  let(:project_id) { 5220065 }
  let(:ticket_id) { 133184178 }
  let(:comment_id) { 74197051 }
  let(:tm) { create_instance }
  let(:project) { tm.project project_id }
  let(:ticket) { project.ticket ticket_id }
  let(:comment_class) { TaskMapper::Provider::Basecamp::Comment }

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

  pending "#comment!" do
    context "with a comment body" do
      let(:comment) { ticket.comment! :body => "New Comment" }

      it "creates a new comment" do
        expect(comment).to be_a comment_class
        epxect(comment.body).to eq "New Comment"
      end
    end
  end
end
