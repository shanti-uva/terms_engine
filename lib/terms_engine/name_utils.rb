module TermsEngine
  module NameUtils
    def self.export(from, to)
      features = Feature.all.order(:fid)
      features = features.where(['fid >= ?', from]) if !from.blank?
      features = features.where(['fid <= ?', to]) if !to.blank?
      latin = WritingSystem.get_by_code('latin')
      tib = WritingSystem.get_by_code('tibt')
      features.each do |f|
        wylie = f.names.where(writing_system: latin).first
        tibetan = f.names.where(writing_system: tib).first
        puts [f.fid, wylie.nil? ? '' : wylie.name, tibetan.nil? ? '' : tibetan.name, f.position].join("\t")
      end
    end
  end
end
