import Config

case System.get_env("APP_ENV") do
  "PROD" ->
    if System.get_env("DOCKER_COMPOSE_MODE") == "HOST" do
      config :rinha_backend, RinhaRepo,
        database: "rinha_backend",
        username: "user",
        password: "pass",
        hostname: "localhost"
    else
      config :rinha_backend, RinhaRepo,
        database: "rinha_backend",
        username: "user",
        password: "pass",
        hostname: "database"
    end

  _ ->
    :noop
end

config :rinha_backend, RinhaRepo, pool_size: System.fetch_env!("DB_CONNS") |> String.to_integer()
