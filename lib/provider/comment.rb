module TaskMapper::Provider
  module Basecamp
    # The comment class for taskmapper-basecamp
    #
    # Do any mapping between taskmapper and your system's comment model here
    # versions of the ticket.
    #
    class Comment < TaskMapper::Provider::Base::Comment
      # declare needed overloaded methods here
      API = ::Basecamp::Comment

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

      def self.create(ticket_id, attributes)
        new_comment = API.new attributes.merge(:todo_item_id => ticket_id)
        new_comment.save

        reloaded_comment = find_bc_comment(ticket_id, new_comment.id)
        self.new reloaded_comment.attributes.merge!(:ticket_id => ticket_id)
      end

      def save
        bc_comment = self.class.find_bc_comment ticket_id, id
        bc_comment.body = self.body
        bc_comment.save
      end

      private
      def self.find_bc_comment(ticket_id, id)
        API.find id, :params => { :todo_item_id => ticket_id }
      end
    end
  end
end
