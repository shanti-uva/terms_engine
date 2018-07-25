#TermsEngine::Engine.routes.draw do
Rails.application.routes.draw do
  resources :recordings
  namespace :admin do
    resources :definition_relations
    resources :definitions
  end
end
