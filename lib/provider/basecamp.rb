module TicketMaster::Provider
  # This is the Basecamp Provider for ticketmaster
  module Basecamp
    include TicketMaster::Provider::Base
    
    # This is for cases when you want to instantiate using TicketMaster::Provider::Basecamp.new(auth)
    def self.new(auth = {})
      TicketMaster.new(:basecamp, auth)
    end
    
    def authorize(auth = {})
      auth[:ssl] = true
      @authentication ||= TicketMaster::Authenticator.new(auth)
      auth = @authentication
      if (auth.domain.nil? and auth.subdomain.nil?) or (auth.token.nil? and (auth.username.nil? and auth.password.nil?))
        raise "Please provide at least an domain and token or username and password)"
      end
      unless auth.token.nil?
        auth.username = auth.token
        auth.password = 'Basecamp'
      end
      if auth.domain.nil? and auth.subdomain
        auth.domain = (auth.subdomain.include?('.') ? auth.subdomain : auth.subdomain + '.basecamphq.com')
      end
      BasecampAPI.establish_connection!(auth.domain, auth.username, auth.password, auth.ssl)
    end

    def valid?
      begin
        !project_count = BasecampAPI::People.find(:me).nil?
      rescue
        false
      end
    end
    
  end
end


