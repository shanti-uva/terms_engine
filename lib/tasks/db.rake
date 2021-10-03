# desc "Explaining what the task does"
require 'terms_engine/name_utils'
require 'terms_engine/import/feature_importation'
require 'terms_engine/import/xml_importation'

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
                  "Syntax: rake db:import:features SOURCE=csv-file-name TASK=task_code LOG_LEVEL=log-level DAYLIGHT=value"
      desc csv_desc
      task features: :environment do
        source = ENV['SOURCE']
        task = ENV['TASK']
        log_level = ENV['LOG_LEVEL']
        if source.blank? || task.blank?
          puts csv_desc
        else
          TermsEngine::FeatureImportation.new("log/import_#{task}_#{Rails.env}.log", log_level.nil? ? Rails.logger.level : log_level.to_i).do_feature_import(filename: source, task_code: task, daylight: ENV['DAYLIGHT'])
        end
      end
      
      xml_desc = "Use to import XML containing terms into DB.\n" +
                  "Syntax: rake db:import:xml SOURCE_FILE=xml-file-name TASK=task_code LOG_LEVEL=log-level SOURCE_ID=source-id AUTHOR=fullname"
      desc xml_desc
      task xml: :environment do
        source_file = ENV['SOURCE_FILE']
        task = ENV['TASK']
        log_level = ENV['LOG_LEVEL']
        source = ENV['SOURCE']
        author_name = ENV['AUTHOR']
        if source_file.blank? || task.blank? || source.blank? || author_name.blank?
          puts xml_desc
        else
          TermsEngine::XmlImportation.new("log/import_#{task}_#{Rails.env}.log", log_level.nil? ? Rails.logger.level : log_level.to_i).do_feature_import(filename: source_file, task_code: task, source: source, author_name: author_name)
        end
      end
    end
    
    desc "Load seeds for terms engine tables"
    task seed: :environment do
      TermsEngine::Engine.load_seed
    end
  end
end