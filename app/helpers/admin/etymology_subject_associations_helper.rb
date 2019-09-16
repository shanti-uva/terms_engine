module Admin::EtymologySubjectAssociationsHelper
  def new_etymology_subject_associations_links(etymology)
    EtymologySubjectAssociation.select('branch_id').distinct.sort_by {|a| a.branch['header']}.collect do |a|
      link_to "#{a.branch['header']} association", new_admin_etymology_etymology_subject_association_path(etymology, branch_id: a.branch_id)
    end.join(" | ").html_safe
  end
end
