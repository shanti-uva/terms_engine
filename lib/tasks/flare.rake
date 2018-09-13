require 'terms_engine/flare_utils'

namespace :terms_engine do
  namespace :flare do
    desc "Reindex all terms in solr. rake kmaps_engine:flare:reindex_all [FROM=fid] [TO=fid] [LEVEL=level]"
    task :reindex_all => :environment do
      TermsEngine::FlareUtils.reindex_all(from: ENV['FROM'], to: ENV['TO'], level: ENV['LEVEL'], letter: ENV['LETTER'], phoneme: ENV['PHONEME'], daylight: ENV['DAYLIGHT'])
    end
  end
end