defmodule RinhaBackend.Application do
  use Application

  require Logger

  @impl true
  def start(_type, _args) do
    connect_to_cluster(:timer.minutes(1))

    children = [
      RinhaRepo,
      Cache,
      {Bandit, plug: HttpServer, port: System.fetch_env!("HTTP_SERVER_PORT")}
    ]

    opts = [strategy: :one_for_one, name: RinhaBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp connect_to_cluster(timeout) do
    do_connect_to_cluster(timeout, System.monotonic_time(:second))
  end

  defp do_connect_to_cluster(timeout, start) do
    nodes =
      System.fetch_env!("BOOTSTRAP_NODES")
      |> String.split(",")
      |> Enum.reject(fn e -> e == "" end)

    sucess = Enum.all?(nodes, fn n -> Node.connect(String.to_atom(n)) == true end)

    if sucess do
      :ok
    else
      if System.monotonic_time(:second) - start > timeout do
        raise "TIEMOUT! Could not connect to cluster!"
      else
        Process.sleep(:timer.seconds(1))
        do_connect_to_cluster(timeout, start)
      end
    end
  end
end
