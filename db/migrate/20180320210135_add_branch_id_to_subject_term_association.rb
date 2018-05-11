class AddBranchIdToSubjectTermAssociation < ActiveRecord::Migration[5.1]
  def up
    add_column :subject_term_associations, :branch_id, :integer
    SubjectTermAssociation.reset_column_information
    SubjectTermAssociation.update_all branch_id: 9310
    change_column :subject_term_associations, :branch_id, :integer, null: false
  end
  
  def down
    remove_column :subject_term_associations, :branch_id
  end
end
