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
        def create(attributes_hash)
          attributes_hash[:todo_list_id] ||= create_todo_list(attributes_hash[:project_id]).id 
          attributes_hash[:content] = attributes_hash[:title]
          project_id = attributes_hash[:project_id]

          todoitem = create_todo_item(attributes_hash)
          todoitem.save ? self.new(todoitem.attributes.merge! :project_id => project_id) : nil
        end

        private
        def delete_fields_from(attributes_hash)
          attributes_hash.delete(:project_id)
          attributes_hash.delete(:title)
        end

        def create_todo_item(attributes_hash)
          delete_fields_from(attributes_hash)
          BasecampAPI::TodoItem.new(attributes_hash)
        end

        def create_todo_list(project_id)
          BasecampAPI::TodoList.create(:project_id => project_id, :name => title)
        end
      end
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
