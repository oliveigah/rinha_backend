import Config

config :rinha_backend, RinhaRepo,
  database: "rinha_backend",
  username: "user",
  password: "pass",
  hostname: "localhost",
  pool_size: System.fetch_env!("DB_CONNS") |> String.to_integer()
