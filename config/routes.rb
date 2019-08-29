#TermsEngine::Engine.routes.draw do
Rails.application.routes.draw do
  resources :features do
    resources :recordings, only: [:index,:show], defaults: { format: 'json' }
  end
  resources :recordings, only: [:show]
  namespace :admin do
    concern :add_author do
      get :add_author, on: :collection
    end

    resources :definitions, concerns: :add_author
    resources :definitions do
      resources :definition_relations
      resources :definition_subject_associations
    end
    resources :definition_relations
    resources :features do
      resources :recordings
      resources :definitions do #, only: [:index, :show]
        get :locate_for_relation, on: :member
      end
      resources :subject_term_associations
    end
  end
  resources :passages, only: [:show] do
    resources :citations
  end
end
