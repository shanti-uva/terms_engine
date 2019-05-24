#TermsEngine::Engine.routes.draw do
Rails.application.routes.draw do
  resources :features do
    resources :recordings, only: [:index,:show], defaults: { format: 'json' }
  end
  resources :recordings, only: [:show]
  namespace :admin do
    resources :definitions do
      resources :definition_relations
    end
    resources :definition_relations
    resources :features do
      resources :definitions do #, only: [:index, :show]
        get :locate_for_relation, on: :member
      end
    end
  end
  resources :passages, only: [:show] do
    resources :citations
  end
end
