# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :tracker2x2,
  ecto_repos: [Tracker2x2.Repo]

# Configures the endpoint
config :tracker2x2, Tracker2x2.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4eX8Qs96Hj5nFHuXsZd61GZJtZoxCGow0kWB4LlgOt5TNhllQjXOVFvYwbSLdJXX",
  render_errors: [view: Tracker2x2.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tracker2x2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :cloak, Cloak.AES.CTR,
  tag: "AES",
  default: true,
  keys: [
    %{tag: <<1>>, key: :base64.decode(System.get_env("CLOAK_KEY")), default: true}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
