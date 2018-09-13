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
    
    def self.wait_if_business_hours(daylight)
      return if daylight.blank?
      now = self.now
      end_time = self.end_time
      if now.wday<6 && self.start_time<now && now<end_time
        delay = self.end_time-now
        puts "#{Time.now}: Resting until #{end_time}..."
        sleep(delay)
      end
    end
    
    def self.reindex_all(options)
      from = options[:from]
      to = options[:to]
      level = options[:level]
      level = level.to_i if !level.blank?
      letter = options[:letter]
      phoneme = options[:phoneme]
      daylight = options[:daylight]
      from_i = from.blank? ? nil : from.to_i
      to_i = to.blank? ? nil : to.to_i
      view = View.get_by_code('roman.scholar')
      fids = nil
      if (!level.blank? && level<=2) || (level.blank? && letter.blank? && phoneme.blank?)
        if level==1
          features = Feature.roots.order(:fid)
        elsif level==2
          if letter.blank?
            fids = Feature.roots.collect do |f|
              children = f.children.order(:fid)
              children = children.where(['fid >= ?', from_i]) if !from_i.nil?
              children = children.where(['fid <= ?', to_i]) if !to_i.nil?
              children.collect(&:fid)
            end.flatten.sort
          else
            features = Feature.get_by_fid(letter.to_i).children.order(:fid)
          end
        else
          features = Feature.where(is_public: true).order(:fid)
        end
        if fids.blank?
          features = features.where(['fid >= ?', from_i]) if !from_i.nil?
          features = features.where(['fid <= ?', to_i]) if !to_i.nil?
          fids = features.collect(&:fid)
        end
      else
        query_array = []
        query_array << "level_tib.alpha_i:#{level}" if !level.blank?
        query_array << "ancestor_ids_tib.alpha:#{letter}" if !letter.blank?
        query_array << "associated_subject_#{Feature::PHONEME_SUBJECT_ID}_ls:#{phoneme}" if !phoneme.blank?
        query = query_array.join(' AND ')
        num_found = Feature.search_by(query)['numFound']
        resp = Feature.search_by(query, fl: 'uid', rows: num_found)['docs']
        fids = resp.collect{|f| f['uid'].split('-').last.to_i}
        fids.sort!
        fids.select!{|fid| fid >= from_i } if !from_i.nil?
        fids.select!{|fid| fid <= to_i } if !to_i.nil?
      end
      count = 0
      current = 0
      puts "#{Time.now}: Indexing of #{fids.size} terms about to start..."
      while current<fids.size
        limit = current + INTERVAL
        limit = fids.size if limit > fids.size
        self.wait_if_business_hours(daylight)
        sid = Spawnling.new do
          puts "Spawning sub-process #{Process.pid}."
          fids[current...limit].each do |fid|
            f = Feature.get_by_fid(fid)
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