defmodule Cache do
  use GenServer

  def init(_) do
    :ets.new(__MODULE__, [
      :set,
      :public,
      :named_table,
      decentralized_counters: true
    ])

    {:ok, nil}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def write(key, val), do: :ets.insert(__MODULE__, {key, val})

  def exists?(key), do: :ets.member(__MODULE__, key)

  def read(key), do: :ets.lookup(__MODULE__, key) |> List.first() |> elem(1)

  def clear(), do: :ets.delete_all_objects(__MODULE__)
end
