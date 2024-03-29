module Admin::SubjectTermAssociationsHelper
  def new_subject_term_associations_links(term)
    SubjectTermAssociation.select('branch_id').distinct.where.not(branch_id: SubjectTermAssociation::LANGUAGE_DETAIL_SUBJECTS.push(SubjectTermAssociation::EXTRA_HIDDEN_SUBJECS).flatten).sort_by {|a| a.branch['header']}.collect do |a|
      "<li>#{link_to a.branch['header'], new_admin_feature_subject_term_association_path(term, branch_id: a.branch_id)}</li>"
    end.join("").html_safe
  end

end
