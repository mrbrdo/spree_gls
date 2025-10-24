require 'spree_gls'
require 'rails'

module SpreeGls
  class Railtie < Rails::Railtie
    railtie_name :spree_gls

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end