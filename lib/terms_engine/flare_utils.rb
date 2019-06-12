require 'kmaps_engine/progress_bar'
require 'kmaps_engine/flare_utils'

module TermsEngine
  class FlareUtils < KmapsEngine::FlareUtils
    include KmapsEngine::ProgressBar
    
    def reindex_all(from:, to:, level:, letter:, phoneme:, daylight:)
      level = level.to_i if !level.blank?
      from_i = from.blank? ? nil : from.to_i
      to_i = to.blank? ? nil : to.to_i
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
      self.reindex_fids(fids, daylight)
    end
  end
end