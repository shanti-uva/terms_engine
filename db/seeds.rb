# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

[ { name: 'Tibetan Alphabetical', code: 'tib.alpha', is_public: true },
  { name: 'English Alphabetical', code: 'eng.alpha', is_public: true }
].each { |p| Perspective.update_or_create(p) }

[ { label: 'is beginning of', asymmetric_label: 'starts with', is_hierarchical: true,
    code: 'is.beginning.of', asymmetric_code: 'begins.with', is_symmetric: false },
  { label: 'heads', asymmetric_label: 'is headed by', is_hierarchical: true,
    code: 'heads', asymmetric_code: 'is.headed.by', is_symmetric: false },
  { label: 'has a conjugation', asymmetric_label: 'is a conjugation of', is_hierarchical: false,
    code: 'is.a.conjugation.of', asymmetric_code: 'has.as.a.conjugation', is_symmetric: false }
].each{ |a| FeatureRelationType.update_or_create(a) }
