Rails.application.routes.draw do
  mount TermsEngine::Engine => "/terms_engine"
end
