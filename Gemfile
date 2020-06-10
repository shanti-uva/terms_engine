source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in terms_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'spawnling'
gem 'passiverecord',              '0.2',          github: 'ambethia/passiverecord'

gem 'activeresource', require: 'active_resource'
gem 'active_resource_extensions', '2.2.3',        github: 'thl/active_resource_extensions',  tag: 'v2.2.3' #path: '../../thl/engines/active_resource_extensions'
gem 'acts_as_family_tree',        '1.2.0',        github: 'thl/acts_as_family_tree',         tag: 'v1.2.0' #path: '../../thl/engines/acts_as_family_tree'
gem 'authenticated_system',       '2.4.0',        github: 'thl/authenticated_system',        tag: 'v2.4.0' #path: '../../thl/engines/authenticated_system'
gem 'complex_dates',              '2.3.0',        github: 'thl/complex_dates',               tag: 'v2.3.0' #path: '../../thl/engines/complex_dates'
gem 'complex_scripts',            '3.1.1',        github: 'thl/complex_scripts',             tag: 'v3.1.1' #path: '../../thl/engines/complex_scripts'
gem 'dictionary_to_terms',        '0.4.1',        github: 'shanti-uva/dictionary_to_terms',  tag: 'v0.4.1' #path: '../dictionary_to_terms'
gem 'flare',                      '1.2.9',        github: 'shanti-uva/flare',                tag: 'v1.2.9' #path: '../flare'
gem 'ffi-icu',                    '0.2.0',        github: 'shanti-uva/ffi-icu',              tag: 'v0.2.0' #path: '../engines/ffi-icu'
gem 'interface_utils',            '2.3.9',        github: 'thl/interface_utils',             tag: 'v2.3.9' #path: '../../thl/engines/interface_utils'
gem 'kmaps_engine',               '5.8.9',        github: 'shanti-uva/kmaps_engine',         tag: 'v5.8.9' #path: '../kmaps_engine'
gem 'shanti_integration',         '3.4.8',        github: 'shanti-uva/shanti_integration',   tag: 'v3.4.8' #path: '../engines/shanti_integration'
gem 'resource_controller',        '0.9.2',        github: 'shanti-uva/resource_controller',  tag: 'v0.9.2' #path: '../resource_controller'

gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
  gem 'pry-rails'
  gem 'pry-byebug'
end
