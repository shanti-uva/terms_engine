Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'stylesheets').to_s
Rails.application.config.assets.paths << Rails.root.join('assets', 'stylesheets', 'terms_engine').to_s
Rails.application.config.assets.precompile.concat(['terms_engine/recordings.js'])
Rails.application.config.assets.precompile.concat(['terms_engine/recordings_admin.js'])
