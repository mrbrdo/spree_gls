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

    module AddGlsSubmenuToMainMenu
      def add_integrations_section(root)
        super

        root.insert_before('integrations',
          ::Spree::Admin::MainMenu::ItemBuilder.new('gls', admin_gls_path).
          with_icon_key('box.svg').
          with_match_path('/gls').
          build)
      end
    end

    def self.activate
      ::Spree::Admin::MainMenu::DefaultConfigurationBuilder.prepend AddGlsSubmenuToMainMenu
    end

    config.to_prepare &method(:activate).to_proc
  end
end
