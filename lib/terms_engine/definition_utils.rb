module TermsEngine
  module DefinitionUtils
    def self.export(**options)
      i = InfoSource.where(code: options[:dictionary_code]).first
      definitions = Definition.joins(:citations).where('citations.info_source' => i).includes(:feature)
      latin = WritingSystem.get_by_code('latin')
      tib = WritingSystem.get_by_code('tibt')
      definitions.each do |d|
        f = d.feature
        next if !f.bod_expression?
        wylie = f.names.where(writing_system: latin).first
        tibetan = f.names.where(writing_system: tib).first
        puts [f.fid, wylie.nil? ? '' : wylie.name, tibetan.nil? ? '' : tibetan.name, f.position, "\"#{d.content}\""].join("\t")
      end
    end
  end
end
