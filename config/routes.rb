#TermsEngine::Engine.routes.draw do
Rails.application.routes.draw do
  resources :features do
    resources :recordings, only: [:index,:show], defaults: { format: 'json' }
  end
  resources :recordings, only: [:show]
  namespace :admin do
    resources :definition_associations, only: [:create]
    resources :definition_relations, :info_sources
    resources :definitions do
      resources :citations, :etymologies, :definition_relations, :definition_subject_associations, :passages
      resources :definition_associations
    end
    resources :etymologies do
      resources :etymology_type_associations, :etymology_subject_associations
    end
    resources :features do
      post :create_tibetan_term, on: :collection
      post :create_english_term, on: :collection
      resources :definitions do #, only: [:index, :show]
        get :locate_for_relation, on: :member
      end
      resources :etymologies, :passages, :recordings, :subject_term_associations
    end
    resources :passages, only: [:show] do
      resources :citations
    end
  end
end
