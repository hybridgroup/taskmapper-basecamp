module TicketMaster::Provider
  module Basecamp
    # Ticket class for ticketmaster-basecamp
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
    class Ticket < TicketMaster::Provider::Base::Ticket
      attr_accessor :list

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
          tickets = BasecampAPI::TodoList.find(:all, :params => {:project_id => project_id}).collect do |list|
            list.todo_items.collect { |item|
              item.attributes['list'] = list
              item
            }
          end.flatten.collect { |ticket| self.new(ticket.attributes.merge!(:project_id => project_id)) }
          search_by_attribute(tickets, options, limit)
        end

        # It expects a single hash
        def create(*options)
          if options.first.is_a?(Hash)
            list_id = options[0].delete(:todo_list_id) || options[0].delete('todo_list_id')
            project_id = options[0].delete(:project_id) || options[0].delete('project_id')
            title = options[0].delete(:title) || options[0].delete('title')
            if list_id.nil? and project_id
              list_id = BasecampAPI::TodoList.create(:project_id => project_id, :name => 'New List').id
            end
            options[0][:todo_list_id] = list_id
            options[0][:content] = title
          end
          something = BasecampAPI::TodoItem.new(options.first)
          something.save
          find_by_id(project_id, something.attributes[:id])
        end
      end

      def status
        self.completed ? 'completed' : 'incomplete'
      end

      def priority
        self.position
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

      def description
        self.content
      end

      def description=(desc)
        self.content = desc
      end

      def assignee
        self.responsible_party_name
      end

      def requestor
        self.creator_name
      end

      def comment!(*options)
        options[0].merge!(:todo_item_id => id) if options.first.is_a?(Hash)
        self.class.parent::Comment.create(*options)
      end

    end
  end
end
