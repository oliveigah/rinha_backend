import Config

config :rinha_backend, RinhaRepo,
  database: "rinha_backend",
  username: "user",
  password: "pass",
  hostname: "database",
  pool_size: 100


config :logger, level: :info
