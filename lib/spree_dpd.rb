require 'dry-configurable'
require 'spree_core'
require 'spree_extension'
require 'spree_dpd/version'
require 'spree_dpd/engine'
require 'spree_dpd/railtie' if defined?(Rails)
require 'sass/rails'

module SpreeDpd
  extend Dry::Configurable

  setting :pickup_time_from,  default: '9:00'
  setting :pickup_time_to,    default: '14:30'
end
