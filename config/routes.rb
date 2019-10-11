#TermsEngine::Engine.routes.draw do
Rails.application.routes.draw do
  resources :features do
    resources :recordings, only: [:index,:show], defaults: { format: 'json' }
  end
  resources :recordings, only: [:show]
  namespace :admin do
    resources :definitions do
      resources :etymologies
      resources :definition_relations
      resources :definition_subject_associations
    end
    resources :definition_relations
    resources :etymologies do
      resources :etymology_type_associations
      resources :etymology_subject_associations
    end
    resources :features do
      post :create_tibetan_term, on: :collection
      resources :definitions do #, only: [:index, :show]
        get :locate_for_relation, on: :member
      end
      resources :etymologies
      resources :recordings
      resources :subject_term_associations
    end
  end
  resources :passages, only: [:show] do
    resources :citations
  end
end
