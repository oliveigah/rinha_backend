defmodule Person do
  alias FTSIndex

  @attr [:id, :apelido, :nome, :nascimento, :stack]

  @str_attr Enum.map(@attr -- [:id], &Atom.to_string/1)

  @fts_attributes [:apelido, :nome, :stack]

  @fts_limit 50

  def create_table() do
    node_list = [node()]

    result =
      :mnesia.create_table(__MODULE__,
        attributes: @attr,
        disc_copies: node_list,
        type: :set,
        index: [:apelido]
      )

    case result do
      {:atomic, :ok} ->
        :ok

      {:aborted, {:already_exists, _table_name}} ->
        :ok
    end
  end

  def get_str_attr, do: @str_attr

  def insert(params) do
    result =
      :mnesia.transaction(fn ->
        case :mnesia.index_read(__MODULE__, params.apelido, 3) do
          [] ->
            new_id = UUID.uuid4()

            new_data =
              Enum.map(@attr, fn
                :id -> new_id
                :stack -> Map.get(params, :stack, [])
                key -> Map.fetch!(params, key)
              end)

            :ok = :mnesia.write(List.to_tuple([__MODULE__ | new_data]))

            :ok =
              Enum.each(@fts_attributes, fn att ->
                FTSIndex.update(att, params[att], new_id)
              end)

            new_id

          _ ->
            :mnesia.abort(:already_taken)
        end
      end)

    case result do
      {:atomic, new_id} -> {:ok, new_id}
      {:aborted, reason} -> {:error, reason}
    end
  end

  def fetch(id) do
    case :mnesia.dirty_read(__MODULE__, id) |> List.first() do
      nil ->
        {:error, :not_found}

      data ->
        [__MODULE__ | vals] = Tuple.to_list(data)
        {:ok, vals_to_map(vals)}
    end
  end

  def full_text_search(term) do
    {result, _} =
      term
      |> FTSIndex.get_candidates_for_term()
      |> Enum.reduce_while({[], 0}, fn {id, attrs}, {acc, counter} ->
        {:ok, person} = fetch(id)

        if Enum.any?(attrs, fn attr -> match_text?(person[attr], term) end) do
          new_acc = [person | acc]
          new_counter = counter + 1

          if new_counter >= @fts_limit,
            do: {:halt, {new_acc, new_counter}},
            else: {:cont, {new_acc, new_counter}}
        else
          {:cont, {acc, counter}}
        end
      end)

    result
  end

  def count(), do: :mnesia.table_info(__MODULE__, :size)

  def clear_tables() do
    :ok = FTSIndex.clear_tables()
    {:atomic, :ok} = :mnesia.clear_table(__MODULE__)
  end

  defp vals_to_map(vals), do: @attr |> Enum.zip(vals) |> Map.new()

  defp match_text?(val, text) when is_list(val),
    do: Enum.any?(val, fn v -> match_text?(v, text) end)

  defp match_text?(val, text) when is_bitstring(val), do: String.contains?(val, text)
end
