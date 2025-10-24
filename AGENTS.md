# Agent Guidelines for spree_gls

## Commands
- **Test**: `bundle exec rake` | `bundle exec rspec spec/path/file_spec.rb` | `bundle exec rspec spec/path/file_spec.rb:42`
- **Setup**: `bundle exec rake test_app` (generates dummy app)

## Code Style
- Ruby 2.7+, Rails engine extending Spree Commerce
- Naming: `snake_case` files/methods, `CamelCase` classes, `SCREAMING_SNAKE_CASE` constants
- Namespace: `Spree::` for models/controllers, plain classes for lib (e.g., `GlsClient`)
- Inherit: Controllers from `Spree::Admin::BaseController`, models from `Spree::Base`
- Imports: `require` non-Rails deps (e.g., `require 'faraday'`), Rails autoloads Spree classes
- Errors: Use `fail` for exceptions, check API status codes/content types
- Config: `GlsClient.configure`, `SpreeGls.config`
- DB: ActiveRecord associations/validations, migrations in `db/migrate/`
- Views: ERB under `app/views/spree/admin/`, partials prefixed `_`
- I18n: Keys in `config/locales/en.yml` and `sl-SI.yml`, use `Spree.t('key')`
- Files: ActiveStorage for attachments (e.g., `has_one_attached :pdf_label`)
- Testing: RSpec + FactoryBot + DatabaseCleaner + Spree helpers. Don't write tests unless asked.
