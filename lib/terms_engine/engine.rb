module TermsEngine
  class Engine < ::Rails::Engine
    # isolate_namespace TermsEngine
    
    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
    end
    
  end
end
