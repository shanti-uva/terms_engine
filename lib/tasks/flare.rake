require 'terms_engine/flare_utils'

namespace :terms_engine do
  namespace :flare do
    desc "Reindex all terms in solr. rake terms_engine:flare:reindex_all [FROM=fid] [TO=fid] [LEVEL=level] [LETTER=letter] [PHONEME=phoneme] [DAYLIGHT=daylight] [LOG_LEVEL=0..5]"
    task :reindex_all => :environment do
      TermsEngine::FlareUtils.new.reindex_all(from: ENV['FROM'], to: ENV['TO'], level: ENV['LEVEL'], letter: ENV['LETTER'], phoneme: ENV['PHONEME'], daylight: ENV['DAYLIGHT'], log_level: ENV['LOG_LEVEL'])
    end
  end
end