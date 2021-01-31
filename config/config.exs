# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :circle,
  ecto_repos: [Circle.Repo]

# Configures the endpoint
config :circle, CircleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "b4nmsTbHsYKmRvLnYvMR54FQET1jG5FPLYwlIHNCjTj20SDLFIopp98L61Ig85Zc",
  render_errors: [view: CircleWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Circle.PubSub,
  live_view: [signing_salt: "3uP/B1+g"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
