require 'spec_helper'

describe TaskMapper::Provider::Basecamp::Project do
  let(:tm) { create_instance }
  let(:project_id) { 5220065 }
  let(:project) { tm.project project_id }
  let(:ticket_id) { 133184178 }
  let(:ticket_class) { TaskMapper::Provider::Basecamp::Ticket }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/projects/#{project_id}.xml", rheaders, fixture_for('projects/5220065'), 200
      mock.get "/projects/#{project_id}/todo_lists.xml?responsible_party=", rheaders, fixture_for('todo_list_with_items'), 200
      mock.get "/todo_items/#{ticket_id}.xml", rheaders, fixture_for('todo_item'), 200
      mock.get "/todo_lists/19700377/todo_items.xml", rheaders, fixture_for('todo_list_with_items'), 200
      mock.get "/todo_lists/19700382/todo_items.xml", rheaders, fixture_for('todo_list_with_items'), 200
      mock.get "/todo_lists/19700819/todo_items.xml", rheaders, fixture_for('todo_list_with_items'), 200
      mock.post "/todo_lists/62504112/todo_items.xml", pheaders, fixture_for('todo_items/62504112_todo_item'), 200
      mock.post '/projects/5220065/todo_lists.xml', pheaders, fixture_for('todo_lists/create'), 200
      mock.post '/todo_lists/9972756/todo_items.xml', pheaders, '', 200
      mock.put "/todo_items/#{ticket_id}.xml", pheaders, fixture_for('todo_item'), 200
    end
  end

  describe "#tickets" do
    context "without arguments" do
      let(:tickets) { project.tickets }

      it "returns an array containing all tickets" do
        expect(tickets).to be_an Array
        expect(tickets.first).to be_a ticket_class
      end
    end

    context "with an array of ticket IDs" do
      let(:tickets) { project.tickets [ticket_id] }

      it "returns an array containing matching tickets" do
        expect(tickets).to be_an Array
        expect(tickets.first).to be_a ticket_class
        expect(tickets.first.id).to eq ticket_id
      end
    end

    context "with a hash containing a project ID" do
      let(:tickets) { project.tickets :id => ticket_id }

      it "returns an array containing the requested ticket" do
        expect(tickets).to be_an Array
        expect(tickets.first).to be_a ticket_class
        expect(tickets.first.id).to eq ticket_id
      end
    end
  end

  describe "#ticket" do
    context "with a ticket ID" do
      let(:ticket) { project.ticket ticket_id }

      it "returns the matching ticket" do
        expect(ticket).to be_a ticket_class
        expect(ticket.id).to eq ticket_id
      end
    end

    describe "#save" do
      let(:ticket) { project.ticket ticket_id }

      it "should update the ticket" do
        ticket.title = "New Ticket Title"
        expect(ticket.save).to be_true
        expect(ticket.title).to eq "New Ticket Title"
      end
    end
  end

  describe "#ticket!" do
    context "with a todo_list_id, title, and description" do
      let(:ticket) do
        project.ticket!(
          :todo_list_id => 9972756,
          :title => 'Ticket #12',
          :description => 'Body'
        )
      end

      it "creates a new ticket" do
        expect(ticket).to be_a ticket_class
        expect(ticket.project_id).to_not be_nil
        expect(ticket.todo_list_id).to eq 9972756
        expect(ticket.title).to eq "Ticket #12"
      end
    end

    context "without a todo_list_id" do
      let(:ticket) do
        project.ticket!(:title => 'Ticket #12', :description => 'Body')
      end

      it "creates a new ticket" do
        expect(ticket).to be_a ticket_class
        expect(ticket.project_id).to eq project.id
        expect(ticket.todo_list_id).to_not be_nil
        expect(ticket.title).to eq "Ticket #12"
      end
    end
  end
end
