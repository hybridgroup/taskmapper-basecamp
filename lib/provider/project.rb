module TaskMapper::Provider
  module Basecamp
    # Project class for taskampper-basecamp
    #
    # Remaps 
    #
    # description => announcement
    # created_at => created_on
    # updated_at => last_changed_on
    class Project < TaskMapper::Provider::Base::Project
      API = BasecampAPI::Project

      def initialize(*backend_info) 
        @system_data ||= {}
        data = backend_info.first
        case data 
        when Hash
          super data.to_hash
        else
          @system_data[:client] = data
          super data.attributes
        end
      end

      def description
        announcement
      end

      def created_at
        created_on.to_time
      rescue
        created_on
      end

      def updated_at
        last_changed_on.to_time
      rescue
        last_changed_on
      end

      def ticket!(attributes_hash)
        provider_parent(self.class)::Ticket.create attributes_hash.merge :project_id => id
      end

      def self.find_by_id(id)
        self.new API.find(id)
      end

      def self.find_by_attributes(attributes = {})
        self.search(attributes)
      end

      def self.search(options = {}, limit = 1000)
        search_by_attribute(self._basecamp_projects, options, limit)
      end

      def self._basecamp_projects
        API.find(:all).collect { |project| self.new project }
      end

      # copy from this.copy(that) copies that into this
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(:title => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:body => comment.body)
            sleep 1
          end
        end
      end

    end
  end
end


