# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :shares,
  ecto_repos: [Shares.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :shares, SharesWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "oTUSX9qhZKEH3uiH4VFMTtnDJxFQ8vXabwy1FudRaM38OupUGIagvCljyDI3MSr8",
  render_errors: [view: SharesWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Shares.PubSub,
  live_view: [signing_salt: "nE633G4W"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
