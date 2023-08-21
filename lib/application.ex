defmodule RinhaBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    init_node()

    children = [
      {Bandit, plug: HttpServer}
    ]

    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp init_node() do
    File.mkdir_p(Application.get_env(:mnesia, :dir))

    :mnesia.create_schema([node()])

    case :mnesia.change_table_copy_type(:schema, node(), :disc_copies) do
      {:atomic, :ok} ->
        :ok

      {:aborted, {:already_exists, _table, _node, _type}} ->
        :ok
    end

    :ok = Person.create_table()
    :ok = FTSIndex.create()

    [Person, FTSIndex.get_tables()]
    |> List.flatten()
    |> :mnesia.wait_for_tables(:timer.seconds(600))
  end
end
