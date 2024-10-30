# Prerequisites

* Apache SOLR
* Postgres
* rvm or rbenv

# Getting Started

Log in to the terms, subjects and places apps in production using your UVA credentials.

Notify amontano of your UVA username and that you've logged in on prod. Amontano will then generate db backups on the gar server. Download all three to your local machine.

Create the terms_development and subjects_development databases, eg

`createdb -U postgres terms_development`

Load the backups (path to db backup is for example only; use your path) eg

`pg_restore -U postgres -d terms_development -1 ~/projects/uva/dbs/terms_production_daily.backup`

For the places database, it's a bit different. 

To get latest places db running locally, you should fetch 
`~/kmaps-apps-infrastructure/database-backups/places_production_daily.backup`, into a local file called `places-2023-11-13.dump`.
Run the following:

`createdb -U postgres places_development`

`psql -U postgres -d places_development`

`CREATE EXTENSION postgis;`

`CREATE EXTENSION postgis_topology;`

`psql -U postgres -d places_development -f /opt/local/share/postgresql15/contrib/postgis-3.4/legacy.sql`

`perl /opt/local/share/postgresql15/contrib/postgis-3.4/postgis_restore.pl places-2023-11-13.dump | psql -U postgres places_development 2> error.txt`



Create the following directory structure wherever you do your development work:

`shanti/`

Clone the terms, subjects and places repos into this dir. Then create another directory inside shanti:

`engines/`

Clone the terms_engine (or whichever engine you'll be workong on) into this dir.

Locate the line for the engine you're working on in the gemfile of the corresponding container app. For example, if you're working on terms, in shanti/terms/Gemfile you'd locate the line for the terms_engine gem. Comment that line out and replace it with 

`gem 'terms_engine', '1.3.0', path: '../engines/terms_engine'` (check the version number in the terms_engine_repo)

Copy any yml.sample files located in the config/ directory, eg 

`cp config/storage.yml.sample config/storage.yml`

In the directory for the parent app (eg if you're working on terms_engine, cd to where you have the "terms" repo) and then

Run `bundle install`

Run `rake webpacker:install`

to precompile assets:

`export NODE_OPTIONS=--openssl-legacy-provider`

`rake assets:precompile RAILS_ENV=development`

and then start the server.

TO RUN MIGRATIONS:

Copy the migrations into the parent application (eg cd into the Terms application root)

`rake terms_engine_engine:install:migrations`

Then run the migrations as you normally would from there.

# TermsEngine
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'terms_engine'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install terms_engine
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
