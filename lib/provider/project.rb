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

      def initialize(*object) 
        if object.first 
          object = object.first
          unless object.is_a? Hash
            hash = {:id => object.id,
                    :created_at => created_on,
                    :updated_at => updated_on,
                    :description => object.announcement,
                    :name => object.name}

          else
            hash = object
          end
          super hash
        end
      end
      
      def description
        announcement
      end
      
      def description=(desc)
        announcement = desc
      end
      
      def created_at
        begin
          created_on.to_time
        rescue
          created_on
        end
      end
      
      def created_at=(created)
        created_on = created
      end
      
      def updated_at
        begin
          last_changed_on.to_time
        rescue
          last_changed_on
        end
      end
      
      def updated_at=(updated)
        last_changed_on = updated
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
        projects = API.find(:all).collect { |project| self.new project }
        search_by_attribute(projects, options, limit)
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


