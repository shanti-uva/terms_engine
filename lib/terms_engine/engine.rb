module TermsEngine
  class Engine < ::Rails::Engine
    # isolate_namespace TermsEngine
    
    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
    end
    
    config.to_prepare do
      # Extending / overriding kmaps_engine controllers
      require_dependency 'admin/citations_controller'
      require_dependency 'terms_engine/admin_citations_controller_extensions'
      Admin::CitationsController.include TermsEngine::AdminCitationsControllerExtensions
      
      require_dependency 'admin/feature_relation_types_controller'
      require_dependency 'terms_engine/admin_feature_relation_types_controller_overrides'
      Admin::FeatureRelationTypesController.prepend TermsEngine::AdminFeatureRelationTypesControllerOverrides
      
      require_dependency 'admin/feature_relations_controller'
      require_dependency 'terms_engine/admin_feature_relations_controller_extensions'
      require_dependency 'terms_engine/admin_feature_relations_controller_overrides'
      Admin::FeatureRelationsController.include TermsEngine::AdminFeatureRelationsControllerExtensions
      Admin::FeatureRelationsController.prepend TermsEngine::AdminFeatureRelationsControllerOverrides
      
      require_dependency 'admin/features_controller'
      require_dependency 'terms_engine/admin_features_controller_extensions'
      Admin::FeaturesController.include TermsEngine::AdminFeaturesControllerExtensions
      
      require_dependency 'admin/notes_controller'
      require_dependency 'terms_engine/admin_notes_controller_extensions'
      Admin::NotesController.include TermsEngine::AdminNotesControllerExtensions
      
      require_dependency 'citations_controller'
      require_dependency 'terms_engine/citations_controller_extensions'
      CitationsController.include TermsEngine::CitationsControllerExtensions
      
      require_dependency 'features_controller'
      require_dependency 'terms_engine/features_controller_extensions'
      FeaturesController.include TermsEngine::FeaturesControllerExtensions
      
      require_dependency 'notes_controller'
      require_dependency 'terms_engine/notes_controller_extensions'
      NotesController.include TermsEngine::NotesControllerExtensions
      
      require_dependency 'sessions_controller'
      require_dependency 'terms_engine/sessions_controller_extensions'
      SessionsController.include TermsEngine::SessionsControllerExtensions
      
      # Extending / overriding authenticated_system controllers
      require_dependency 'authenticated_system/users_controller'
      require_dependency 'terms_engine/users_controller_overrides'
      AuthenticatedSystem::UsersController.prepend TermsEngine::UsersControllerOverrides

      # Extending / overriding kmaps_engine models
      require_dependency 'feature'
      require_dependency 'terms_engine/feature_extensions'
      require_dependency 'terms_engine/feature_overrides'
      Feature.include TermsEngine::FeatureExtensions
      Feature.prepend TermsEngine::FeatureOverrides
      
      require_dependency 'feature_relation'
      require_dependency 'terms_engine/feature_relation_extensions'
      FeatureRelation.include TermsEngine::FeatureRelationExtensions
      
      require_dependency 'feature_relation_type'
      require_dependency 'terms_engine/feature_relation_type_extensions'
      FeatureRelationType.include TermsEngine::FeatureRelationTypeExtensions
      
      require_dependency 'illustration'
      require_dependency 'terms_engine/illustration_extensions'
      Illustration.include TermsEngine::IllustrationExtensions
      
      require_dependency 'perspective'
      require_dependency 'terms_engine/perspective_extensions'
      Perspective.include TermsEngine::PerspectiveExtensions
      
      # overriding kmaps_engine helpers
      require_dependency 'admin_helper'
      require_dependency 'concerns/terms_engine/admin_helper_overrides'
      AdminHelper.prepend TermsEngine::AdminHelperOverrides
    end
  end
end
