module TermsEngine
  require 'erb'
  require 'yaml'

  class Configuration
  #
  # TermsEngine::Configuration is configured via the config/terms_engine.yml file, which
  # contains properties keyed by environment name. A sample terms_engine.yml file
  # would look like:
  # production:
  #   server:
  #     hostname: terms.kmaps.virginia.edu
  #     port: 80
  #     scheme: https
  #     path: /
  #
  # development:
  #   server:
  #     hostname:  localhost
  #     port: 80
  #     scheme: http
  #     path: /terms-server
  #
  # test:
  #   server:
  #     hostname: localhost
  #     port: 80
  #     scheme: http
  #     path: /test-server

    attr_writer :user_configuration

    #
    # The host name at which to connect to Terms Server. Default 'localhost'.
    #
    # ==== Returns
    #
    # String:: host name
    #
    def hostname
      unless defined?(@hostname)
        @hostname ||= user_configuration_from_key('server', 'hostname')
        @hostname ||= default_hostname
      end
      @hostname
    end
    #
    # The port at which to connect to Terms server.
    # Defaults to 80
    #
    # ==== Returns
    #
    # Integer:: port
    #
    def port
      unless defined?(@port)
        @port ||= user_configuration_from_key('server', 'port')
        @port   = @port.to_i if !@port.blank?
      end
      @port
    end
    #
    # The scheme to use, http or https.
    # Defaults to http
    #
    # ==== Returns
    #
    # String:: scheme
    #
    def scheme
      unless defined?(@scheme)
        @scheme ||= user_configuration_from_key('server', 'scheme')
        @scheme ||= default_scheme
      end
      @scheme
    end

    #
    # The url path to the Terms server.
    # Default '/server'.
    #
    # ==== Returns
    #
    # String:: path
    #
    def path
      unless defined?(@path)
        @path ||= user_configuration_from_key('server', 'path')
        @path ||= default_path
      end
      @path
    end

    def default_hostname
      'localhost'
    end

    def default_scheme
      'http'
    end

    def default_path
      ''
    end

    def server_url
      res = "#{scheme}://"
      res << "#{hostname}"
      res << ":#{port}" if !port.blank?
      res << "#{path}"
    end
    
    def self.server_url
      @@configuration ||= Configuration.new
      @@configuration.server_url
    end

    #
    # return a specific key from the user configuration in config/terms_engine.yml
    #
    # ==== Returns
    #
    # Mixed:: requested_key or nil
    #
    def user_configuration_from_key( *keys )
      keys.inject(user_configuration) do |hash, key|
        hash[key] if hash
      end
    end

    #
    # Memoized hash of configuration options for the current Rails environment
    # as specified in config/terms_engine.yml
    #
    # ==== Returns
    #
    # Hash:: configuration options for current environment
    #
    def user_configuration
      @user_configuration ||=
        begin
          path = File.join(::Rails.root, 'config', 'terms_engine.yml')
          if File.exist?(path)
            File.open(path) do |file|
              processed = ERB.new(file.read).result
              YAML.load(processed)[::Rails.env]
            end
          else
            {}
          end
        end
    end
  end
end
