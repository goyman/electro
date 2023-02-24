# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :electro, ElectroWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "YB3agzoUjNqr68DhZQsZj36juCMZQRww3mMb2NJd7hDdIg+Go2SHqEd4Vd7s+svC",
  render_errors: [
    view: ElectroWeb.ErrorView,
    accepts: ~w(html json),
    layout: false
  ],
  pubsub_server: Electro.PubSub,
  live_view: [signing_salt: "mxK7SEY0"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args: ~w(js/app.js --bundle
       --target=es2017 --outdir=../priv/static/assets
       --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :phoenix_copy,
  default: [
    debounce: 100,
    source: Path.expand("../assets/vendor", __DIR__),
    destination: Path.expand("../priv/static/assets/vendor/", __DIR__)
  ]

inventory_path =
  System.get_env("INVENTORY_PATH") ||
    raise """
    environment variable INVENTORY_PATH is missing.
    Point it to your inventory directory.
    """

config :electro,
  inventory_path: inventory_path,
  octopart_token: System.get_env("OCTOPART_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
