import Config

config :rinha_backend, RinhaRepo,
  database: "rinha_backend_test",
  username: "user",
  password: "pass",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

System.put_env("HTTP_SERVER_PORT", "4000")
System.put_env("BOOTSTRAP_NODES", "")
