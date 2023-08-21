defmodule RinhaBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    File.mkdir_p(Application.get_env(:mnesia, :dir))

    connect_to_cluster()
    init_node()

    children = [
      NodeMonitor,
      {Bandit, plug: HttpServer, port: System.fetch_env!("HTTP_SERVER_PORT")}
    ]

    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp init_node() do
    if Node.list() == [] do
      :mnesia.create_schema([node()])

      case :mnesia.change_table_copy_type(:schema, node(), :disc_copies) do
        {:atomic, :ok} ->
          :ok

        {:aborted, {:already_exists, _table, _node, _type}} ->
          :ok
      end

      :ok = Person.create_table()
      :ok = FTSIndex.create()
    end

    :mnesia.wait_for_tables([Person | FTSIndex.get_tables()], :timer.seconds(600))
  end

  defp connect_to_cluster() do
    System.fetch_env!("BOOTSTRAP_NODES")
    |> String.split(",")
    |> Enum.each(fn node ->
      case Node.connect(String.to_atom(node)) do
        true ->
          Logger.info("Successfully connected to node #{node}!")

        false ->
          Logger.info("Fail to connected to node #{node}!")

        :ignored ->
          Logger.info("Fail to connected to node #{node}!")
      end
    end)
  end
end
