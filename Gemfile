source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails'

# Use SCSS for stylesheets
gem 'sass-rails'

# Declare your gem's dependencies in terms_engine.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'hpricot', github: 'ycorredius/hpricot'#, '>= 0.8.6'
gem 'spawnling'

gem 'activeresource', require: 'active_resource'
gem 'active_resource_extensions', '2.2.7',        github: 'thl/active_resource_extensions',  tag: 'v2.2.7' #path: '../../thl/engines/active_resource_extensions'
gem 'acts_as_family_tree',        '1.2.4',        github: 'thl/acts_as_family_tree',         tag: 'v1.2.4' #path: '../../thl/engines/acts_as_family_tree'
gem 'authenticated_system',       '2.4.4',        github: 'thl/authenticated_system',        tag: 'v2.4.4' #path: '../../thl/engines/authenticated_system'
gem 'complex_dates',              '2.4.2',        github: 'thl/complex_dates',               tag: 'v2.4.2' #path: '../../thl/engines/complex_dates'
gem 'complex_scripts',            '3.1.8',        github: 'thl/complex_scripts',             tag: 'v3.1.8' #path: '../../thl/engines/complex_scripts'
gem 'dictionary_to_terms',        '0.4.2',        github: 'shanti-uva/dictionary_to_terms',  tag: 'v0.4.2' #path: '../engines/dictionary_to_terms'
gem 'interface_utils',            '2.4.2',        github: 'thl/interface_utils',             tag: 'v2.4.2' #path: '../../thl/engines/interface_utils'
gem 'ffi-icu',                    '0.2.2',        github: 'shanti-uva/ffi-icu',              tag: 'v0.2.2' #path: '../engines/ffi-icu'
gem 'flare',                      '1.4.0',        github: 'shanti-uva/flare',                tag: 'v1.4.0' #path: '../engines/flare'
gem 'kmaps_engine',               '6.7.2',        github: 'shanti-uva/kmaps_engine',         tag: 'v6.7.2' #path: '../engines/kmaps_engine'
gem 'resource_controller',        '0.9.5',        github: 'shanti-uva/resource_controller',  tag: 'v0.9.5' #path: '../engines/resource_controller'
gem 'shanti_integration',         '3.6.1',        github: 'shanti-uva/shanti_integration',   tag: 'v3.6.1' #path: '../engines/shanti_integration'

gem 'rails-observers', github: 'rails/rails-observers'
gem 'actionpack-page_caching'
#gem 'actionpack-action_caching'
gem 'actionpack-action_caching', github: 'rails/actionpack-action_caching'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
