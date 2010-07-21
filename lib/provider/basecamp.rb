module TicketMaster::Provider
  # This is the Basecamp Provider for ticketmaster
  module Basecamp
    include TicketMaster::Provider::Base
    
    # This is for cases when you want to instantiate using TicketMaster::Provider::Basecamp.new(auth)
    def self.new(auth = {})
      TicketMaster.new(:basecamp, auth)
    end
    
    # declare needed overloaded methods here
    
  end
end


