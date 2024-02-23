Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets').to_s
Rails.application.config.assets.paths << Rails.root.join('assets', 'stylesheets', 'terms_engine').to_s
Rails.application.config.assets.precompile.concat(['terms_engine/recordings.js','terms_engine/recordings_admin.js',
                                                   'terms_engine/subject_term_associations_admin.js',
                                                   'terms_engine/definition_association_admin.js',
                                                   'terms_engine/definition_subject_associations_admin.js',
                                                   'terms_engine/etymology_type_associations_admin.js',
                                                   'terms_engine/feature_subject_associations_admin.js',
                                                   'terms_engine/etymology_subject_associations_admin.js',
                                                   'terms_engine/relation_subject_associations_admin.js',
                                                   'terms_engine/feature_relation_admin.js',
                                                   'terms_engine/related-section-initializer.js',
                                                   'terms_engine/features_admin_accordion.js',
                                                   'terms_engine/definitions_admin_accordion.js'
                                                   ])
