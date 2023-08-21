defmodule NodeMonitor do
  use GenServer

  require Logger

  @tables [Person | FTSIndex.get_tables()]
  def init(_args) do
    :ok = :net_kernel.monitor_nodes(true)
    {:ok, nil}
  end

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def handle_info({:nodeup, node}, _state) do
    Logger.info("Node #{node} is connected to #{node()}")
    {:ok, [_ | _] = _nodes} = :mnesia.change_config(:extra_db_nodes, Node.list())

    case :mnesia.change_table_copy_type(:schema, node, :disc_copies) do
      {:atomic, :ok} ->
        :ok

      {:aborted, {:already_exists, _table, _node, _type}} ->
        :ok
    end

    Enum.each(@tables, fn table ->
      case :mnesia.add_table_copy(table, node, :disc_copies) do
        {:atomic, :ok} ->
          :ok

        {:aborted, {:already_exists, _table_name, _node}} ->
          :ok
      end
    end)

    {:noreply, nil}
  end

  def handle_info({:nodedown, node}, _state) do
    Logger.info("Node #{node} was disconected from #{node()}")
    {:noreply, nil}
  end
end
