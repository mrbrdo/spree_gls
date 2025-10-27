module SpreeGls
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_gls'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    module ShipmentWithGlsTracking
      def tracked?
        super || shipping_method.code&.start_with?("gls")
      end
    end

    def self.activate
      ::Spree::Shipment.prepend ShipmentWithGlsTracking
    end

    config.to_prepare &method(:activate).to_proc
  end
end
