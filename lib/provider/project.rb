module TicketMaster::Provider
  module Basecamp
    # Project class for ticketmaster-basecamp
    #
    # Remaps 
    #
    # description => announcement
    # created_at => created_on
    # updated_at => last_changed_on
    class Project < TicketMaster::Provider::Base::Project
      API = BasecampAPI::Project
      
      def description
        announcement
      end
      
      def description=(desc)
        announcement = desc
      end
      
      def created_at
        created_on
      end
      
      def created_at=(created)
        created_on = created
      end
      
      def updated_at
        last_changed_on
      end
      
      def updated_at=(updated)
        last_changed_on = updated
      end
      
      def ticket!(*options)
        options[0].merge!(:project_id => id) if options.first.is_a?(Hash)
        self.class.parent::Ticket.create(*options)
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


