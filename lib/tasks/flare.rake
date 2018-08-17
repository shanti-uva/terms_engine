namespace :terms_engine do
  namespace :flare do
    desc "Reindex all terms in solr. rake kmaps_engine:flare:reindex_all [FROM=fid] [TO=fid] [LEVEL=level]"
    task :reindex_all => :environment do
      from = ENV['FROM']
      to = ENV['TO']
      level = ENV['LEVEL']
      from_i = from.blank? ? nil : from.to_i
      to_i = to.blank? ? nil : to.to_i
      view = View.get_by_code('roman.scholar')
      if level.blank?
        features = Feature.where(is_public: true).order(:fid)
        features = features.where(['fid >= ?', from_i]) if !from_i.nil?
        features = features.where(['fid <= ?', to_i]) if !to_i.nil?
      else
        num_found = Feature.search_by("level_tib.alpha_i:#{level}")['numFound']
        fids = Feature.search_by("level_tib.alpha_i:#{level}", {rows: num_found})['docs'].collect{ |d| d['id'].split('-').last.to_i}.sort
        fids.select!{|fid| fid >= from_i } if !from_i.nil?
        fids.select!{|fid| fid <= to_i } if !to_i.nil?
        features = fids.collect{ |fid| Feature.get_by_fid(fid) }
      end
      count = 0
      current = 0
      interval = 100
      puts "#{Time.now}: Indexing of #{features.size} terms about to start..."
      while current<features.size
        limit = current + interval
        limit = features.size if limit > features.size
        sid = Spawnling.new do
          puts "Spawning sub-process #{Process.pid}."
          features[current...limit].each do |f|
            if f.index
              name = f.prioritized_name(view)
              puts "#{Time.now}: Reindexed #{name.name if !name.blank?} (#{f.fid})."
            else
              puts "#{Time.now}: #{f.fid} failed."
            end
          end
          Feature.commit
        end
        Spawnling.wait([sid])
        current = limit
      end
    end
  end
end