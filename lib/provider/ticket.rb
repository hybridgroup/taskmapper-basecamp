module TaskMapper::Provider
  module Basecamp
    # Ticket class for taskmapper-basecamp
    #
    #
    # * status => completed (either completed or incomplete)
    # * priority => position
    # * title => TodoList#name - TodoItem#content (up to 100 characters)
    # * resolution => completed (either completed or '')
    # * updated_at => completed_on
    # * description => content
    # * assignee => responsible_party_name (read-only)
    # * requestor => creator_name (read-only)
    # * project_id
    class Ticket < TaskMapper::Provider::Base::Ticket
      def initialize(*options)
        @system_data ||= {}
        @cache ||= {}
        first = options.first
        case first
        when Hash
          super(first.to_hash)
        else
          @system_data[:client] = first
          super(first.attributes)
        end
      end

      class << self

        def find_by_id(project_id, id)
          find_by_attributes(project_id, {:id => id}).first
        end

        def find_by_attributes(project_id, attributes = {})
          search(project_id, attributes)
        end

        def search(project_id, options = {}, limit = 1000)
          tickets = project_todo_lists(project).map { |ti| self.new ti.attributes.merge :project_id => project_id }
            #todo_items(project_id).map {|ti| self.new ti.attributes.merge :project_id => project_id }
          search_by_attribute(tickets, options, limit)
        end

        # It expects a single hash
        def create(attributes_hash)
          todo_item_hash = create_todo_item_hash attributes_hash
          todo_item = create_todo_item todo_item_hash

          return nil unless todo_item.save

          todo_item.project_id = attributes_hash[:project_id]
          todo_item.todo_list_id = todo_item_hash[:todo_list_id]
          self.new(todo_item)
        end

        private
        def project_todo_lists(project_id)
          ::Basecamp::TodoList.find(:all, :params => {:project_id => project_id, :responsible_party => ''})
        end

        def todo_items(project_id)
          project_todo_lists(project_id).map { |l| l.todo_items }.flatten
        end


        def create_todo_item_hash(ticket_hash)
          a = ticket_hash
          validate_ticket_hash a
          todo_item_hash = {
            :content => a[:title],
            :position => a[:priority] || 1,
            :todo_list_id => a[:todo_list_id] || create_todo_list({
            :project_id => a[:project_id], 
            :name => "#{a[:title]} list"}).id
          }
        end

        def create_todo_item(attributes_hash)
          ::Basecamp::TodoItem.new(attributes_hash)
        end

        def validate_ticket_hash(attributes_hash)
          title = attributes_hash[:title]
          raise ArgumentError.new "Title is required" if title.nil? or title.empty?
        end

        def create_todo_list(attributes)
          ::Basecamp::TodoList.create(attributes)
        end
      end

      def copy_to(todo_item)
        todo_item.completed = status
        todo_item.position = priority
        todo_item.name = title
        todo_item.content = title
        todo_item.completed = resolution
        todo_item.responsible_party_name = assignee
        todo_item.creator_name = requestor
        todo_item
      end

      def save
        todo_item = ::Basecamp::TodoItem.find id, :params => { :todo_list_id => todo_list_id }
        copy_to(todo_item).save
      end

      def todo_list_id
        self['todo_list_id'].to_i
      end

      def status
        self.completed ? 'completed' : 'incomplete'
      end

      def priority
        self.position
      end

      def resolution
        self.completed ? self.completed : 'In Progress'
      end

      def priority=(pri)
        self.position = pri
      end

      def title
        self.content
      end

      def title=(titl)
        self.content = titl
      end

      def updated_at=(comp)
        self.completed_on = comp
      end

      def updated_at
        self.completed_on.to_time
      rescue NoMethodError
        Time.now
      end

      def description
        self.content
      end

      def description=(desc)
        self.content = desc
      end

      def assignee
        self.responsible_party_name ? self.responsible_party_name : 'Unassigned'
      end

      def requestor
        self.creator_name
      end

      def comment!(attributes)
        Comment.create id, attributes
      end

    end
  end
end
