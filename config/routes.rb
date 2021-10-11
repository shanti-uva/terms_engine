#TermsEngine::Engine.routes.draw do
Rails.application.routes.draw do
  concern :notable_citable do
    resources :notes, :citations
  end
  resources :features do
    resources :recordings, only: [:index,:show], defaults: { format: 'json' }
  end
  resources :recordings, only: [:show]
  namespace :admin do
    resources :definition_relations, :info_sources
    resources :definitions do
      resources :citations, :etymologies, :definition_relations, :definition_subject_associations, :passages
      resources :definition_associations, except: [:new, :index]
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
  resources :definitions, concerns: :notable_citable, only: ['show', 'index']
  resources :passages, concerns: :notable_citable, only: ['show', 'index']
  resources :passage_translations, concerns: :notable_citable, only: ['show', 'index']
  resources :translation_equivalents, concerns: :notable_citable, only: ['show', 'index']
end
