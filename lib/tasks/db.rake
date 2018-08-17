# desc "Explaining what the task does"
require 'terms_engine/name_utils'
require 'terms_engine/import/feature_importation'

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
    
    namespace :import do
      csv_desc = "Use to import CSV containing terms into DB.\n" +
                    "Syntax: rake db:import:features SOURCE=csv-file-name TASK=task_code"
      desc csv_desc
      task features: :environment do
        source = ENV['SOURCE']
        task = ENV['TASK']
        if source.blank? || task.blank?
          puts csv_desc
        else
          TermsEngine::FeatureImportation.new.do_feature_import(source, task)
        end
      end
    end
    
    desc "Load seeds for terms engine tables"
    task seed: :environment do
      TermsEngine::Engine.load_seed
    end
  end
end