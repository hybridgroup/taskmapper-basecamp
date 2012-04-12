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
        def create(arguments_for_ticket)
          list_id = arguments_for_ticket.delete(:todo_list_id)
          project_id = arguments_for_ticket.delete(:project_id)
          title = arguments_for_ticket.delete(:title)
          if list_id.nil?
            list_id = create_todo_list(list_id, project_id, title).id
          end
          arguments_for_ticket[:todo_list_id] = list_id
          arguments_for_ticket[:content] = title
          todo_item = BasecampAPI::TodoItem.new(arguments_for_ticket)
          todo_item.save ? self.new(todo_item.attributes.merge!(:project_id => project_id)) : nil
        end

        private
        def create_todo_list(list_id, project_id, title)
          BasecampAPI::TodoList.create(:project_id => project_id, :name => title)
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
