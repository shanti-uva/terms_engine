require 'terms_engine/application_settings'
require "terms_engine/engine"
require 'terms_engine/configuration'
require 'terms_engine/has_passages'

I18n.load_path += Dir[File.join(__dir__, '..', 'config', 'locales', '**', '*.yml')]

module TermsEngine
  # Your code goes here...
end
