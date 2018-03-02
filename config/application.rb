require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RubyBlockchain
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib")

    Thread.abort_on_exception = true

    def every(length_of_time)
      Thread.new do
        loop do
          sleep length_of_time
          yield
        end
      end
    end

    every 10.seconds do
      Client.instance.gossip

      if Client.instance.peers.empty?
        puts "There are no peers yet..."
      else
        puts "Gossipping with peers on the following ports: #{Client.instance.peers.join(', ')}"
      end

      puts Blockchain.instance.compute_balances

    end

  end
end
