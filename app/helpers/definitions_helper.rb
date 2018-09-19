module DefinitionsHelper
  def definition_node_classes(is_child,level=0)
    css_classes = ['terms-definition-node']
    css_class = 'terms-def-child'
    if is_child && level == 2
      css_class << '-2'
    end
    css_classes << css_class
    css_classes.join(' ')
  end

  def index_to_text(index)
    index = index.to_s.gsub(/-/,'.')
    if !index.include? '.'
      index << '.'
    end
    index
  end
end
