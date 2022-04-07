# Spree DPD

## Installation

1. Add this extension to your Gemfile with this line:
        
        gem 'spree_dpd', github: 'mrbrdo/spree_dpd'

2. Install the gem using Bundler:

        bundle install
        
3. Configure:

        DpdClient.configure(
          username: ENV['DPD_USER'],
          password: ENV['DPD_PASS'],
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
