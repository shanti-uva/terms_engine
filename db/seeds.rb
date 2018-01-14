# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Perspective.update_or_create name: 'Tibetan Alphabetical', code: 'tib.alpha', is_public: true

[ { is_symmetric: true,  label: 'is beginning of', asymmetric_label: 'starts with', code: 'is.beginning.of', is_hierarchical: true},
].each{|a| FeatureRelationType.update_or_create(a)}