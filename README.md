# Spree GLS

## Installation

1. Add this extension to your Gemfile with this line:
        
        gem 'spree_gls', github: 'mrbrdo/spree_gls'

2. Install the gem using Bundler and copy migrations:

        bundle install
        rake spree_gls:install:migrations
        
3. Configure:

        GlsApi.configure(
          username: ENV['GLS_USER'],
          password: ENV['GLS_PASS'],
          client_number: ENV['GLS_CLIENT_NUMBER'],
          sender_address: {
            name: "Company",
            street: "Street name",
            house_number: "123",
            zip_code: "1000",
            city: "City",
            country_iso_code: "SI",
            phone: "Phone no.",
            email: "email@example.com",
            contact_name: "Contact Person"
          })

3. Restart your server

        If your server was running, restart it so that it can find the assets properly.
