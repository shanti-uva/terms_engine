# desc "Explaining what the task does"
namespace :terms_engine do
  namespace :db do
    namespace :schema do
      desc "Load schema for terms engine tables"
      task :load do
        ENV['SCHEMA'] = File.join(TermsEngine::Engine.paths['db'].existent.first, 'schema.rb')
        Rake::Task['db:schema:load'].invoke
      end
    end
    desc "Load seeds for terms engine tables"
    task :seed => :environment do
      TermsEngine::Engine.load_seed
    end
  end
end