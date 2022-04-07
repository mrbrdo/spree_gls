require 'spree_dpd'
require 'rails'

module SpreeDpd
  class Railtie < Rails::Railtie
    railtie_name :spree_dpd

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end