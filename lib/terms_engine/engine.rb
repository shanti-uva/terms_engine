module TermsEngine
  class Engine < ::Rails::Engine
    # isolate_namespace TermsEngine
    initializer :loader do |config|
      require 'terms_engine/extension/feature_model'
      require 'terms_engine/extension/feature_controller'
      require 'terms_engine/extension/illustration_model'
      require 'terms_engine/has_model_sentences'
      require 'terms_engine/has_passages'

      Feature.send :include, TermsEngine::Extension::FeatureModel
      FeaturesController.send :include, TermsEngine::Extension::FeatureController
      Illustration.send :include, TermsEngine::Extension::IllustrationModel
    end

    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
    end
    
  end
end
