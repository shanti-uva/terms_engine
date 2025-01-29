#TermsEngine::Engine.routes.draw do
Rails.application.routes.draw do
  concern :notable_citable do
    resources :notes, :citations
  end
  resources :features do
    resources :recordings, only: [:index,:show], defaults: { format: 'json' }
    post :parse, on: :collection
  end
  resources :recordings, only: [:show]
  namespace :admin do
    resource :assistant, only: [:show, :create]
    concern :add_author do
      get :add_author, on: :collection
    end
    resources :definition_relations
    resources :info_sources do
      get :prioritize, on: :collection, to: 'info_sources#prioritize'
      post :prioritize, on: :collection, to: 'info_sources#set_priorities'
    end
    resources :definitions do
      resources :citations, :etymologies, :definition_relations, :definition_subject_associations, :passages, :passage_translations
      
      resources :notes, concerns: :add_author
      #resources :passages do
      #  resources :passage_translations
      #end
      resources :definition_associations, except: [:new, :index]
    end
    resources :enumerations
    resources :etymologies do
      resources :etymology_type_associations, :etymology_subject_associations
      resources :notes, concerns: :add_author
    end
    resources :features do
      post :create_tibetan_term, on: :collection
      post :create_english_term, on: :collection
      resources :definitions do #, only: [:index, :show]
        get :locate_for_relation, on: :member
      end
      resources :enumerations, :etymologies, :passages, :recordings, :subject_term_associations
    end
    resources :passages, only: [:show] do
      resources :citations
      resources :notes, concerns: :add_author
    end
    resources :passages do
      resources :passage_translations
    end
    resources :passage_translations, only: [:show] do
      resources :citations
      resources :notes, concerns: :add_author
    end
  end
  resources :definitions, concerns: :notable_citable, only: ['show', 'index']
  resources :definition_associations, concerns: :notable_citable, only: ['show', 'index']
  resources :etymologies, concerns: :notable_citable, only: ['show', 'index']
  resources :passages, concerns: :notable_citable, only: ['show', 'index']
  resources :passage_translations, concerns: :notable_citable, only: ['show', 'index']
  resources :non_phoneme_term_associations, concerns: :notable_citable, only: ['show', 'index']
  resources :translation_equivalents, concerns: :notable_citable, only: ['show', 'index']
end
