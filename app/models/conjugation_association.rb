class ConjugationAssociation < RelationSubjectAssociation

  BRANCH_ID=1787

  default_scope { where(branch_id: BRANCH_ID) }

end
