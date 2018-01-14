# desc "Explaining what the task does"
namespace :terms_engine do
  namespace :db do
    desc "Load seeds for kmaps engine tables"
    task :seed => :environment do
      TermsEngine::Engine.load_seed
    end
  end
end