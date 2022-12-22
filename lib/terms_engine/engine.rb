module TermsEngine
  class Engine < ::Rails::Engine
    # isolate_namespace TermsEngine
    initializer :sweepers do |config|
      observers = [InfoSourceSweeper]
      Rails.application.config.active_record.observers ||= []
      Rails.application.config.active_record.observers += observers
      observers.each { |o| o.instance }
    end
    
    initializer :loader do |config|
      require 'terms_engine/extension/admin_features_controller'
      require 'terms_engine/extension/admin_feature_relations_controller'
      require 'terms_engine/extension/admin_feature_relation_types_controller'
      require 'terms_engine/extension/admin_citations_controller'
      require 'terms_engine/extension/citations_controller'
      require 'terms_engine/extension/feature_controller'
      require 'terms_engine/extension/feature_model'
      require 'terms_engine/extension/feature_relation_model'
      require 'terms_engine/extension/feature_relation_type_model'
      require 'terms_engine/extension/illustration_model'
      require 'terms_engine/extension/perspective_model'
      require 'terms_engine/has_model_sentences'

      Feature.send :include, TermsEngine::Extension::FeatureModel
      CitationsController.send :include, TermsEngine::Extension::CitationsController
      FeaturesController.send :include, TermsEngine::Extension::FeatureController
      FeatureRelation.send :include, TermsEngine::Extension::FeatureRelationModel
      FeatureRelationType.send :include, TermsEngine::Extension::FeatureRelationTypeModel
      Illustration.send :include, TermsEngine::Extension::IllustrationModel
      Admin::CitationsController.send :include, TermsEngine::Extension::AdminCitationsController
      Admin::FeaturesController.send :include, TermsEngine::Extension::AdminFeaturesController
      Admin::FeatureRelationsController.send :include, TermsEngine::Extension::AdminFeatureRelationsController
      Admin::FeatureRelationTypesController.send :include, TermsEngine::Extension::AdminFeatureRelationTypesController
      Perspective.send :include, TermsEngine::Extension::PerspectiveModel
    end

    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
    end
    
  end
end
