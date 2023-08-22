defmodule ReleaseTasks do
  @app :rinha_backend

  def migrate do
    Application.load(@app)

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def create_db do
    Application.load(@app)

    for repo <- Application.fetch_env!(@app, :ecto_repos) do
      repo.__adapter__().storage_up(repo.config())
    end
  end
end
