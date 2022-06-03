require 'kmaps_engine/flare_utils'
require 'terms_engine/flare_utils'

namespace :terms_engine do
  namespace :flare do
    desc "Reindex all terms in solr. rake terms_engine:flare:reindex_all [FROM=fid] [TO=fid] [LEVEL=level] [LETTER=letter] [PHONEME=phoneme] [DAYLIGHT=daylight] [LOG_LEVEL=0..5]"
    task :reindex_all => :environment do
      TermsEngine::FlareUtils.new("log/reindexing_#{Rails.env}.log", ENV['LOG_LEVEL']).reindex_all(from: ENV['FROM'], to: ENV['TO'], level: ENV['LEVEL'], letter: ENV['LETTER'], phoneme: ENV['PHONEME'], daylight: ENV['DAYLIGHT'])
    end
    
    desc "Reindex all english and tibetan expressions. rake terms_engine:flare:reindex_expressions [FROM=fid] [TO=fid] [DAYLIGHT=daylight]"
    task :reindex_expressions => :environment do
      TermsEngine::FlareUtils.new("log/reindexing_#{Rails.env}.log", ENV['LOG_LEVEL']).reindex_expressions(from: ENV['FROM'], to: ENV['TO'], daylight: ENV['DAYLIGHT'])
    end
    
    desc "Reindexes features updated after last full reindex."
    task :reindex_stale_since_all => :environment do
      KmapsEngine::FlareUtils.reindex_stale_since_all([DefinitionAssociation, DefinitionRelation, DefinitionSubjectAssociation, Definition, EtymologySubjectAssociation, Etymology, ModelSentence, Passage, PhonemeTermAssociation, Recording, RelationSubjectAssociation, SubjectTermAssociation])
    end
  end
end