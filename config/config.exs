import Config

config :rinha_backend, RinhaRepo,
  database: "rinha_backend",
  username: "user",
  password: "pass",
  hostname: "localhost",
  pool_size: 10

config :rinha_backend, ecto_repos: [RinhaRepo]

import_config "#{config_env()}.exs"
