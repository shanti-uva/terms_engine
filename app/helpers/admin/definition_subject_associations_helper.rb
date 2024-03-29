module Admin::DefinitionSubjectAssociationsHelper
  def new_definition_subject_associations_links(definition)
    DefinitionSubjectAssociation.select('branch_id').distinct.sort_by {|a| a.branch['header']}.collect do |a|
      "<li>#{link_to a.branch['header'], new_admin_definition_definition_subject_association_path(definition, branch_id: a.branch_id)}</li>"
    end.join("").html_safe
  end
end
