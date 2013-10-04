module TaskMapper::Provider
  module Basecamp
    class Comment < TaskMapper::Provider::Base::Comment
      API = BasecampAPI::Comment

      # Public: Method to create a new Comment
      #
      # comment - a hash of Comment attributes
      #
      # Returns a new Comment instance
      def initialize(*comment)
        comment = comment.first if comment.is_a?(Array)
        super comment
      end

      # Public: Saves a Comment to Basecamp
      #
      # Returns a boolean indicating if the comment was saved or not
      def save
        comment = API.find(self[:id])
        comment.update_attributes(self.to_hash)
      end

      class << self
        # Public: Finds a specific Comment by it's project_id, ticket_id, and
        # comment_id
        #
        # project_id - ID of the project the comment belongs to
        # ticket_id - ID of the comment to find
        # comment_id - ID of the comment to find
        #
        # Returns a matching Comment instance
        def find_by_id(project_id, ticket_id, comment_id)
          find_by_attributes(project_id, ticket_id, { :id => comment_id }).first
        end

        # Public: Searches all Comments belonging to a ticket with a hash of
        # attributes
        #
        # project_id - ID of project the ticket belongs to
        # ticket_id - ID of the ticket whose comments should be searched
        # attributes - hash of attributes to search with
        #
        # Returns a Comment instance
        def find_by_attributes(project_id, ticket_id, attributes = {})
          search_by_attribute find_all(project_id, ticket_id), attributes
        end

        # Public: Finds all Comments associated with a Project/Ticket
        #
        # project_id - ID of the project the ticket belongs to
        # ticket_id - ID of the ticket to fetch comments for
        #
        # Returns an array of Comments
        def find_all(project_id, ticket_id)
          comments = API.find :all, :params => { :todo_item_id => ticket_id }
          comments.collect do |comment|
            attrs = comment.attributes
            attrs.merge!({ :project_id => project_id, :ticket_id => ticket_id })
            attrs[:author] = attrs.delete(:author_name)
            self.new attrs
          end.flatten
        end

        # Public: Creates a new Comment based on passed attributes, and persists
        # it to Basecamp
        #
        # attrs - hash of attributes used when creating/persisting the new
        #         Comment
        #
        # Returns a new Comment instance
        def create(attrs = {})
          attrs.fetch(:body) do
            raise ArgumentError, "A body must be supplied to make a new Comment"
          end

          attrs[:todo_item_id] = attrs.fetch(:ticket_id)

          comment = API.new(attrs)
          comment.save
          find_by_id attrs[:project_id], attrs[:ticket_id], comment.id
        end
      end
    end
  end
end
