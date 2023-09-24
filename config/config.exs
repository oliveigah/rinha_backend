import Config


config :rinha_backend, RinhaRepo,
  database: "rinha_backend",
  username: "user",
  password: "pass",
  hostname: "localhost",
  queue_target: 1_000,
  queue_interval: 5_000

config :rinha_backend, ecto_repos: [RinhaRepo]

import_config "#{config_env()}.exs"
