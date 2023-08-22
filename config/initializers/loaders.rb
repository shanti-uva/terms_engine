ActiveSupport.on_load(:feature) do
  require 'terms_engine/extensions/feature_model'
  include TermsEngine::Extension::FeatureModel
end
ActiveSupport.on_load(:citations_controller) do
  require 'terms_engine/extensions/citations_controller'
  include TermsEngine::Extension::CitationsController
end
ActiveSupport.on_load(:features_controller) do
  require 'terms_engine/extensions/feature_controller'
  include TermsEngine::Extension::FeatureController
end
ActiveSupport.on_load(:feature_relation) do
  require 'terms_engine/extensions/feature_relation_model'
  include TermsEngine::Extension::FeatureRelationModel
end
ActiveSupport.on_load(:feature_relation_type) do
  require 'terms_engine/extensions/feature_relation_type_model'
  include TermsEngine::Extension::FeatureRelationTypeModel
end
ActiveSupport.on_load(:illustration) do
  require 'terms_engine/extensions/illustration_model'
  include TermsEngine::Extension::IllustrationModel
end
ActiveSupport.on_load(:admin_citations_controller) do
  require 'terms_engine/extensions/admin_citations_controller'
  include TermsEngine::Extension::AdminCitationsController
end
ActiveSupport.on_load(:admin_features_controller) do
  require 'terms_engine/extensions/admin_features_controller'
  include TermsEngine::Extension::AdminFeaturesController
end
ActiveSupport.on_load(:admin_feature_relations_controller) do
  require 'terms_engine/extensions/admin_feature_relations_controller'
  include TermsEngine::Extension::AdminFeatureRelationsController
end
ActiveSupport.on_load(:admin_feature_relation_types_controller) do
  require 'terms_engine/extensions/admin_feature_relation_types_controller'
  include TermsEngine::Extension::AdminFeatureRelationTypesController
end
ActiveSupport.on_load(:perspective) do
  require 'terms_engine/extensions/perspective_model'
  include TermsEngine::Extension::PerspectiveModel
end