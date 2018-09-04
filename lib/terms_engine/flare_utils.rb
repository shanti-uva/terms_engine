module TermsEngine
  module FlareUtils
    INTERVAL = 100
    START_HOUR=8
    END_HOUR = 17
    
    def self.now
      Time.now
    end
    
    def self.start_time
      now = self.now
      Time.new(now.year, now.month, now.day, START_HOUR)
    end
    
    def self.end_time
      now = self.now
      Time.new(now.year, now.month, now.day, END_HOUR)
    end
    
    def self.wait_if_business_hours
      now = self.now
      end_time = self.end_time
      if self.start_time<now && now<end_time
        delay = self.end_time-now
        puts "#{Time.now}: Resting until #{end_time}..."
        sleep(delay)
      end
    end
    
    def self.reindex_all(options)
      from = options[:from]
      to = options[:to]
      level = options[:level]
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
      puts "#{Time.now}: Indexing of #{features.size} terms about to start..."
      while current<features.size
        limit = current + INTERVAL
        limit = features.size if limit > features.size
        self.wait_if_business_hours
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