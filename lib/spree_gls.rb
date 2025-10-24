require 'dry-configurable'
require 'spree_core'
require 'spree_extension'
require 'spree_gls/version'
require 'spree_gls/engine'
require 'spree_gls/railtie' if defined?(Rails)
require 'sass/rails'

module SpreeGls
  extend Dry::Configurable
end
