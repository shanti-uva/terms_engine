module TermsEngine
  module ApplicationSettings
    def self.import_interval
      interval = Rails.cache.fetch("application_settings/#{InterfaceUtils::Server.get_domain}/import_interval", :expires_in => 1.day) do
        int = InterfaceUtils::ApplicationSettings.settings['import.interval']
        int = nil if int.blank?
        int
      end
      return interval
    end
  end
end
