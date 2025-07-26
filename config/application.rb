require_relative "boot"

# require "rails/all"
require "rails"                     # core
require "active_model/railtie"      # validations, serializers
require "active_record/railtie"     # ORM
# require "active_job/railtie"        # background jobs
require "action_controller/railtie" # controllers, routing
# require "action_mailer/railtie"     # mailers
require "action_view/railtie"       # view rendering
# require "action_cable/engine"       # WebSockets
require "propshaft/engine"         # asset pipeline
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rashboard
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :utc
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
