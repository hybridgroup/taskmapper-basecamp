module TaskMapper::Provider
  # This is the Basecamp Provider for taskmapper
  module Basecamp
    include TaskMapper::Provider::Base

    # This is for cases when you want to instantiate using
    # TaskMapper::Provider::Basecamp.new(auth)
    def self.new(auth = {})
      TaskMapper.new(:basecamp, auth)
    end

    def configure(auth)
      BasecampAPI.establish_connection!(
        auth.domain,
        auth.username,
        auth.password,
        auth.ssl
      )
    end

    def authorize(auth = {})
      auth[:ssl] = true
      auth = @authentication ||= TaskMapper::Authenticator.new(auth)
      validate_auth_params auth
      configure auth
    end

    def valid?
      !project_count = BasecampAPI::Person.me.nil?
    rescue ActiveResource::UnauthorizedAccess
      false
    end

    private
    def validate_auth_params(auth)
      no_domain = (auth.domain.nil? && auth.subdomain.nil?)
      no_auth = (auth.token.nil? && (auth.username.nil? && auth.password.nil?))

      if no_domain
        message = "Please provide a Basecamp domain or subdomain"
        raise TaskMapper::Exception.new message
      end

      if no_auth
        message = "Please provide a Basecamp domain or subdomain"
        raise TaskMapper::Exception.new message
      end

      if auth.token
        auth.username = auth.token
        auth.password = 'Basecamp'
      end

      if auth.domain.nil? and auth.subdomain
        if auth.subdomain.include? '.'
          auth.domain = auth.subdomain
        else
          auth.domain = auth.subdomain + ".basecamphq.com"
        end
      end
    end
  end
end
