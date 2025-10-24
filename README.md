# Spree GLS

## Installation

1. Add this extension to your Gemfile with this line:
        
        gem 'spree_gls', github: 'mrbrdo/spree_gls'

2. Install the gem using Bundler:

        bundle install
        
3. Configure:

        GlsClient.configure(
          username: ENV['GLS_USER'],
          password: ENV['GLS_PASS'],
          api_url: 'https://easyship.si/api/',
          sender_data: {
            name: "Company",
            street: "Street address",
            postal: "Postal code",
            city: "City",
            phone: "Phone no."
          })

3. Restart your server

        If your server was running, restart it so that it can find the assets properly.
