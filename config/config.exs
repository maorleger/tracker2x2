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
  secret_key_base: "nnHewN6qj2k5KSatOW7rT4Ghlhvf5ARTTQjMVDUIkGXeo7+l5Qj8kT+R6yde/sYY",
  render_errors: [view: Tracker2x2.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Tracker2x2.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"



# %% Coherence Configuration %%   Don't remove this line
config :coherence,
  user_schema: Tracker2x2.User,
  repo: Tracker2x2.Repo,
  module: Tracker2x2,
  logged_out_url: "/",
  email_from_name: "Your Name",
  email_from_email: "yourname@example.com",
  opts: [:rememberable, :authenticatable, :recoverable, :lockable, :trackable, :unlockable_with_token, :registerable]

config :coherence, Tracker2x2.Coherence.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "your api key here"
# %% End Coherence Configuration %%
