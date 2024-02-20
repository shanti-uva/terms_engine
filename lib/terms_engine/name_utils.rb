module TermsEngine
  module NameUtils
    def self.export(**options) #from, to
      if (options[:fid].blank?)
        features = Feature.all.order(:fid)
        features = features.where(['fid >= ?', options[:from]]) if !options[:from].blank?
        features = features.where(['fid <= ?', options[:to]]) if !options[:to].blank?
      else
        features = Feature.where(fid: options[:fid])
      end
      latin = WritingSystem.get_by_code('latin')
      tib = WritingSystem.get_by_code('tibt')
      features.each do |f|
        next if !f.bod_expression?
        wylie = f.names.where(writing_system: latin).first
        tibetan = f.names.where(writing_system: tib).first
        puts [f.fid, wylie.nil? ? '' : wylie.name, tibetan.nil? ? '' : tibetan.name, f.position].join("\t")
      end
    end
  end
end
