# desc "Explaining what the task does"
require 'terms_engine/name_utils'
require 'terms_engine/definition_utils'
require 'terms_engine/import/feature_importation'
require 'terms_engine/import/feature_name_match'
require 'terms_engine/import/filter'
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
      schema_export_desc = "Export names.\n" +
            "Syntax: rake terms_engine:db:export:names FID=fid | [FROM=fid] [TO=fid]"
      desc schema_export_desc
      task names: :environment do
        options = { from: ENV['FROM'], to: ENV['TO'], fid: ENV['FID'] }
        if options.values.any?
          TermsEngine::NameUtils.export(**options)
        else
          puts schema_export_desc
        end
      end
      
      def_export_desc = "Export definitions.\n" +
            "Syntax: rake terms_engine:db:export:definitions DICTIONARY_CODE=dict_code"
      desc def_export_desc
      task definitions: :environment do
        options = { dictionary_code: ENV['DICTIONARY_CODE'] }
        if options.values.any?
          TermsEngine::DefinitionUtils.export(**options)
        else
          puts def_export_desc
        end
      end
    end
    
    namespace :import do
      import_features_desc = "Use to import CSV containing terms into DB.\n" +
                  "Syntax: rake terms_engine:db:import:features SOURCE=csv-file-name TASK=task_code LOG_LEVEL=log-level DAYLIGHT=value PERSPECTIVE=perspective-code"
      desc import_features_desc
      task features: :environment do
        source = ENV['SOURCE']
        task = ENV['TASK']
        perspective_code = ENV['PERSPECTIVE']
        
        log_level = ENV['LOG_LEVEL']
        if source.blank? || task.blank?
          puts import_features_desc
        else
          TermsEngine::FeatureImportation.new("log/import_#{task}_#{Rails.env}.log", log_level.nil? ? Rails.logger.level : log_level.to_i).do_feature_import(filename: source, task_code: task, perspective_code: perspective_code)
        end
      end
      
      import_xml_desc = "Use to import XML containing terms into DB.\n" +
                  "Syntax: rake terms_engine:db:import:xml SOURCE_FILE=xml-file-name TASK=task_code LOG_LEVEL=log-level SOURCE=source-name SOURCE_ID=source-id AUTHOR=fullname COLLECTION=collection-name"
      desc import_xml_desc
      task xml: :environment do
        source_file = ENV['SOURCE_FILE']
        task = ENV['TASK']
        log_level = ENV['LOG_LEVEL']
        source = ENV['SOURCE']
        source_id = ENV['SOURCE_ID']
        author_name = ENV['AUTHOR']
        collection_name = ENV['COLLECTION']
        if source_file.blank? || task.blank? || source.blank? || source_id.blank? || author_name.blank? || collection_name.blank?
          puts import_xml_desc
        else
          TermsEngine::XmlImportation.new("log/import_#{task}_#{Rails.env}.log", log_level.nil? ? Rails.logger.level : log_level.to_i).do_feature_import(filename: source_file, task_code: task, source: source, source_id: source_id, author_name: author_name, collection: collection_name)
        end
      end
      
      import_match_desc = "Matches rows in CSV input1 with input2 based on column matching_column and produces third CSV output.\n"+
        "Syntax: rake terms_engine:db:import:match INPUT1=csv-file-name INPUT2=csv-file-name OUTPUT=csv-file-name MATCHING_COL=col-name"
      desc import_match_desc
      task match: :environment do
        input1 = ENV['INPUT1']
        input2 = ENV['INPUT2']
        output = ENV['OUTPUT']
        matching_column = ENV['MATCHING_COL']
        if input1.blank? || input2.blank? || output.blank? || matching_column.blank?
          puts import_match_desc
        else
          TermsEngine::FeatureNameMatch.match(input1: input1, input2: input2, output: output, matching_column: matching_column)
        end
      end
    end
    
    namespace :filter do
      get_feat_filter_desc = "Use to infer fids from CSV containing terms in tibetan and wylie.\n" +
                  "Syntax: rake terms_engine:db:filter:get_features SOURCE=csv-file-name"
      desc get_feat_filter_desc
      task get_features: :environment do
        source = ENV['SOURCE']
        if source.blank?
          puts get_feat_filter_desc
        else
          TermsEngine::Filter.new.do_feature_filter(filename: source)
        end
      end
      
      get_parents_filter_desc = "Use to infer parents from CSV containing term in tibetan.\n" +
                  "Syntax: rake terms_engine:db:filter:get_parents SOURCE=csv-file-name"
      desc get_parents_filter_desc
      task get_parents: :environment do
        source = ENV['SOURCE']
        if source.blank?
          puts get_parents_filter_desc
        else
          TermsEngine::Filter.new.do_parent_filter(filename: source)
        end
      end
    end
    
    desc "Load seeds for terms engine tables"
    task seed: :environment do
      TermsEngine::Engine.load_seed
    end
  end
end