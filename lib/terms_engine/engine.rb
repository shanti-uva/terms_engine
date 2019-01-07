module TermsEngine
  class Engine < ::Rails::Engine
    # isolate_namespace TermsEngine
    initializer :loader do |config|
      require 'terms_engine/extension/feature_model'
      require 'terms_engine/extension/feature_controller'
      require 'terms_engine/extension/illustration_model'
      require 'terms_engine/extension/citations_controller'
      require 'terms_engine/has_model_sentences'

      Feature.send :include, TermsEngine::Extension::FeatureModel
      FeaturesController.send :include, TermsEngine::Extension::FeatureController
      Illustration.send :include, TermsEngine::Extension::IllustrationModel
      CitationsController.send :include, TermsEngine::Extension::CitationsController
    end

    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
    end
    
  end
end
