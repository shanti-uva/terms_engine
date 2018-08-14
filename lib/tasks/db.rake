# desc "Explaining what the task does"
require 'terms_engine/name_utils'

namespace :terms_engine do
  namespace :db do
    namespace :schema do
      desc "Load schema for terms engine tables"
      task :load do
        ENV['SCHEMA'] = File.join(TermsEngine::Engine.paths['db'].existent.first, 'schema.rb')
        Rake::Task['db:schema:load'].invoke
      end
    end

    namespace :export do
      desc "Export names"
      task names: :environment do
        from = ENV['FROM']
        to = ENV['TO']
        fid = ENV['FID']
        if fid.blank?
          TermsEngine::NameUtils.export(from, to)
        else
          TermsEngine::NameUtils.export(fid, fid)
        end
      end
    end
    
    desc "Load seeds for terms engine tables"
    task seed: :environment do
      TermsEngine::Engine.load_seed
    end
  end
end