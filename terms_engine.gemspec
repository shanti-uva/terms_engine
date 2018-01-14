$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "terms_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "terms_engine"
  s.version     = TermsEngine::VERSION
  s.authors     = ["Andres Montano"]
  s.email       = ["amontano@virginia.edu"]
  s.homepage    = "http://terms.kmaps.virginia.edu"
  s.summary     = "Engine that used by terms app which contains the term specific locales, controllers, models and views not found in kmaps engine."
  s.description = "Engine that used by terms app which contains the term specific locales, controllers, models and views not found in kmaps engine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.1.4"

  s.add_development_dependency "pg"
end
