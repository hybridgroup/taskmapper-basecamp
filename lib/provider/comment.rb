module TicketMaster::Provider
  module Basecamp
    # The comment class for ticketmaster-basecamp
    #
    # Do any mapping between Ticketmaster and your system's comment model here
    # versions of the ticket.
    #
    class Comment < TicketMaster::Provider::Base::Comment
      # declare needed overloaded methods here
      API = BasecampAPI::Comment

      def initialize(*object)
        if object.first
          object = object.first
          unless object.is_a? Hash
            hash = {:id => object.id,
                    :body => object.body,
                    :author => object.author_name,
                    :created_at => object.created_at,
                    :project_id => object.project_id,
                    :ticket_id => object.ticket_id}
          else
            hash = object
          end
          super hash
        end
      end

      def self.find_by_id(project_id, ticket_id, id)
        basecamp_comment = self::API.find(id, :params => {:todo_item_id => ticket_id})
        self.new basecamp_comment.attributes.merge!(:project_id => project_id, :ticket_id => ticket_id)
      end

      def self.find_by_attributes(project_id, ticket_id, attributes = {})
        self.search(project_id, ticket_id, attributes)
      end

      def self.search(project_id, ticket_id, options = {}, limit = 1000)
        comments = API.find(:all, :params => {:todo_item_id => ticket_id}).collect {|c| self.new(c.attributes.merge!(:project_id => project_id, :ticket_id => ticket_id)) }
        search_by_attribute(comments, options, limit)
      end

    end
  end
end
