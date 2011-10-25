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
      def self.find_by_id(project_id, id)
        self.search(project_id, {'id' => id}).first
      end
      
      def self.find_by_attributes(project_id, attributes = {})
        self.search(project_id, attributes)
      end
      
      def self.search(project_id, options = {}, limit = 1000)
        tickets = BasecampAPI::TodoList.find(:all, :params => {:project_id => project_id}).collect do |list|
          list.todo_items.collect { |item|
            item.attributes['list'] = list
            item
            }
          end.flatten.collect { |ticket| self.new(ticket, ticket.attributes.delete('list')) }
        search_by_attribute(tickets, options, limit)
      end
      
      # It expects a single hash
      def self.create(*options)
        if options.first.is_a?(Hash)
          list_id = options[0].delete(:todo_list_id) || options[0].delete('todo_list_id')
          project_id = options[0].delete(:project_id) || options[0].delete('project_id')
          if list_id.nil? and project_id
            list_id = BasecampAPI::TodoList.create(:project_id => project_id, :name => 'New List').id
          end
          options[0][:todo_list_id] = list_id
        end
        something = BasecampAPI::TodoItem.new(options.first)
        something.save
        self.new something
      end
      
      def initialize(ticket, list = nil)
        @system_data ||= {}
        @cache ||= {}
        @list = list
        case ticket
          when Hash
            super(ticket.to_hash)
          else
            @system_data[:client] = ticket
            self.prefix_options ||= @system_data[:client].prefix_options if @system_data[:client].prefix_options
            super(ticket.attributes)
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
        "#{@list.name} - #{content[0..100]}"
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
