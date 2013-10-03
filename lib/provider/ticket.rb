module TaskMapper::Provider
  module Basecamp
    class Ticket < TaskMapper::Provider::Base::Ticket

      # Public: Method to make a new Ticket.
      #
      # ticket - a hash of Ticket attributes
      #
      # Returns a new Ticket instance
      def initialize(ticket)
        super ticket
      end

      class << self
        # Public: Creates a new Ticket based on a passed hash of attributes, and
        # persists it to Basecamp
        #
        # attrs - hash of Ticket attributes to use when creating/persisting
        #         the new Ticket
        #
        # Returns a Ticket instance
        def create(attrs)
          # Raise error if no title has been provided
          attrs.fetch(:title) do
            raise ArgumentError, "A title must be supplied to make a new Ticket"
          end

          attrs[:todo_list_id] ||= BasecampAPI::TodoList.create(
            :project_id => attrs[:project_id],
            :name => "#{attrs[:title]} list"
          ).id

          todo_hash = convert_hash_from_ticket_to_todo attrs

          todo = BasecampAPI::TodoItem.new(todo_hash)
          todo.save

          todo_attrs = convert_hash_from_todo_to_ticket todo.attributes
          todo_attrs[:project_id] = attrs[:project_id]
          todo_attrs[:todo_list_id] = attrs[:todo_list_id]

          self.new todo_attrs
        end

        # Public: Finds a particular Ticket by it's project_id and ticket_id
        #
        # project_id - ID of the project the ticket belongs to
        # ticket_id - ID of the ticket to find
        #
        # Returns a Ticket instance
        def find_by_id(project_id, ticket_id)
          find_by_attributes(project_id, { :id => ticket_id }).first
        end

        # Public: Searches all tickets for a project with a hash of attributes
        #
        # project_id - ID of the project who's tickets should be searched
        # attributes - hash of attributes to search with
        #
        # Returns an array of Tickets
        # Examples:
        #
        #  find_by_attributes 1234567890, { :id => 2 }
        #  #=> [<Ticket id:1 project_id:1234567890>]
        def find_by_attributes(project_id, attributes = {})
          search_by_attribute find_all(project_id), attributes
        end

        # Public: Finds all Tickets belonging to a project
        #
        # project_id - ID of the project to fetch tickets for
        #
        # Returns an array of Tickets
        def find_all(project_id)
          lists = find_project_todo_lists project_id
          todos = lists.collect { |list| extract_todos_from_todo_list list }
          todos.flatten.uniq.collect do |todo|
            todo[:project_id] = project_id
            self.new todo
          end.flatten
        end

        private
        # Private: Finds all TodoLists in Basecamp belonging to a project
        #
        # project_id - the project to find TodoLists for
        #
        # Returns an array of Basecamp::TodoLists
        def find_project_todo_lists(project_id)
          BasecampAPI::TodoList.find(
            :all,
            :params => {
              :project_id => project_id,
              :responsible_party => ''
            }
          )
        end

        # Private: Extracts Todo objects from a TodoList and converts them into
        # Tickets
        #
        # todo_list - a BaseCamp::TodoList to extract tickets from
        #
        # Returns an array of Hashes containing Todo data
        def extract_todos_from_todo_list(todo_list)
          todos = todo_list.todo_items.collect { |t| t.todo_items }.flatten
          todos.collect do |todo|
            attrs = todo.attributes
            attrs.merge! :todo_list_id => todo_list.id
            convert_hash_from_todo_to_ticket attrs
          end
        end

        # Private: Converts a hash's attributes from a Basecamp Todo into the
        # standard TaskMapper Ticket interface
        #
        # hash - hash of Todo attributes to make into a Ticket
        #
        # Returns a Hash ready to be turned into a Ticket
        def convert_hash_from_todo_to_ticket(hash)
          hash = hash.dup
          hash[:creator_name].strip!.lstrip! if hash[:creator_name]
          hash[:title] = hash.delete(:content).strip.lstrip
          hash[:priority] = hash.delete(:position)
          hash[:status] = hash.delete(:completed) ? "completed" : "incomplete"
          hash[:created_at] = hash.delete(:created_on)
          hash
        end

        # Private: Converts a hash's attributes from a TaskMapper Ticket into
        # a format that can be persisted to a Basecamp Todo.
        #
        # hash - hash of Ticket attributes to turn into a Todo
        #
        # Returns a hash ready to be turned into a Todo
        def convert_hash_from_ticket_to_todo(hash)
          hash = hash.dup
          hash[:content] = hash.delete(:title)
          hash[:position] = hash.delete(:priority) || 1
          hash
        end
      end
    end
  end
end
