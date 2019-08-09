module Admin::SubjectTermAssociationsHelper
  def new_subject_term_associations_links(term)
    SubjectTermAssociation.select('branch_id').distinct.sort_by {|a| a.branch['header']}.collect do |a|
      link_to "#{a.branch['header']} association", new_admin_feature_subject_term_association_path(term, branch_id: a.branch_id)
    end.join(" | ").html_safe
  end
end
