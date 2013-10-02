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

      def initialize(*data)
        @system_data ||= {}
        data = data.first if data.is_a? Array
        @system_data[:client] = data
        super data.attributes
      end

      def description
        announcement
      end

      def created_at
        begin
          Time.parse created_on
        rescue
          created_on
        end
      end

      def updated_at
        begin
          Time.parse last_changed_on
        rescue
          last_changed_on
        end
      end

      def ticket!(attributes_hash)
        Ticket.create attributes_hash.merge(:project_id => id)
      end

      class << self
        def find_by_id(id)
          self.new API.find(id)
        end

        def find_by_attributes(attributes = {})
          search(attributes)
        end

        def search(options = {}, limit = 1000)
          projects = API.find(:all).collect { |project| self.new project }
          search_by_attribute(projects, options, limit)
        end
      end

      # copy from this.copy(that) copies that into this
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(
            :title => ticket.title,
            :description => ticket.description
          )

          ticket.comments.each do |comment|
            copy_ticket.comment!(:body => comment.body)
            sleep 1
          end
        end
      end
    end
  end
end
