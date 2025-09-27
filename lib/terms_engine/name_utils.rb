module TermsEngine
  module NameUtils
    def self.export(fid:, from:, to:) #from, to
      if (fid.blank?)
        features = Feature.all.order(:fid)
        features = features.where(['fid >= ?', from]) if !from.blank?
        features = features.where(['fid <= ?', to]) if !to.blank?
      else
        features = Feature.where(fid: fid)
      end
      tib = WritingSystem.get_by_code('tibt')
      wylie = OrthographicSystem.get_by_code('thl.ext.wyl.translit')
      phonetic = PhoneticSystem.get_by_code('thl.simple.transcrip')
      features.each do |f|
        next if !f.bod_expression?
        tibetan_name = f.names.roots.where(writing_system: tib).first
        next if tibetan_name.nil?
        relation = tibetan_name.child_relations.where(orthographic_system: wylie).first
        wylie_name = relation&.child_node
        relation = tibetan_name.child_relations.where(phonetic_system: phonetic).first
        phonetic_name = relation&.child_node
        #wylie_name = f.names.where(writing_system: latin).first
        #tibetan_name = f.names.where(writing_system: tib).first
        puts [f.fid, tibetan_name.name, wylie_name.nil? ? '' : wylie_name.name, phonetic_name.nil? ? '' : phonetic_name.name].join("\t")
      end
    end
  end
end
