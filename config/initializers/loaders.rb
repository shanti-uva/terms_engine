ActiveSupport.on_load(:admin_citations_controller) do
  require_dependency 'terms_engine/admin_citations_controller_extensions'
  include TermsEngine::AdminCitationsControllerExtensions
end

ActiveSupport.on_load(:admin_feature_relation_types_controller) do
  require_dependency 'terms_engine/admin_feature_relation_types_controller_overrides'
  prepend TermsEngine::AdminFeatureRelationTypesControllerOverrides
end

ActiveSupport.on_load(:admin_feature_relations_controller) do
  require_dependency 'terms_engine/admin_feature_relations_controller_extensions'
  require_dependency 'terms_engine/admin_feature_relations_controller_overrides'
  include TermsEngine::AdminFeatureRelationsControllerExtensions
  prepend TermsEngine::AdminFeatureRelationsControllerOverrides
end

ActiveSupport.on_load(:admin_features_controller) do
  require_dependency 'terms_engine/admin_features_controller_extensions'
  include TermsEngine::AdminFeaturesControllerExtensions
end

ActiveSupport.on_load(:admin_notes_controller) do
  require_dependency 'terms_engine/admin_notes_controller_extensions'
  include TermsEngine::AdminNotesControllerExtensions
end

ActiveSupport.on_load(:citations_controller) do
  require_dependency 'terms_engine/citations_controller_extensions'
  include TermsEngine::CitationsControllerExtensions
end

ActiveSupport.on_load(:features_controller) do
  require_dependency 'terms_engine/features_controller_extensions'
  include TermsEngine::FeaturesControllerExtensions
end

ActiveSupport.on_load(:notes_controller) do
  require_dependency 'terms_engine/notes_controller_extensions'
  include TermsEngine::NotesControllerExtensions
end

ActiveSupport.on_load(:sessions_controller) do
  require_dependency 'terms_engine/sessions_controller_extensions'
  include TermsEngine::SessionsControllerExtensions
end

ActiveSupport.on_load(:authenticated_system_users_controller) do
  require_dependency 'terms_engine/users_controller_overrides'
  prepend TermsEngine::UsersControllerOverrides
end

ActiveSupport.on_load(:feature) do
  require_dependency 'terms_engine/feature_extensions'
  require_dependency 'terms_engine/feature_overrides'
  include TermsEngine::FeatureExtensions
  prepend TermsEngine::FeatureOverrides
end

ActiveSupport.on_load(:feature_relation) do
  require_dependency 'terms_engine/feature_relation_extensions'
  include TermsEngine::FeatureRelationExtensions
end

ActiveSupport.on_load(:feature_relation_type) do
  require_dependency 'terms_engine/feature_relation_type_extensions'
  include TermsEngine::FeatureRelationTypeExtensions
end

ActiveSupport.on_load(:illustration) do
  require_dependency 'terms_engine/illustration_extensions'
  include TermsEngine::IllustrationExtensions
end

ActiveSupport.on_load(:perspective) do
  require_dependency 'terms_engine/perspective_extensions'
  include TermsEngine::PerspectiveExtensions
end