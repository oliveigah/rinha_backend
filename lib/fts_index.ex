defmodule FTSIndex do
  @letter_tables %{
    "a" => :FTS_INDEX_A,
    "b" => :FTS_INDEX_B,
    "c" => :FTS_INDEX_C,
    "d" => :FTS_INDEX_D,
    "e" => :FTS_INDEX_E,
    "f" => :FTS_INDEX_F,
    "g" => :FTS_INDEX_G,
    "h" => :FTS_INDEX_H,
    "i" => :FTS_INDEX_I,
    "j" => :FTS_INDEX_J,
    "k" => :FTS_INDEX_K,
    "l" => :FTS_INDEX_L,
    "m" => :FTS_INDEX_M,
    "n" => :FTS_INDEX_N,
    "o" => :FTS_INDEX_O,
    "p" => :FTS_INDEX_P,
    "q" => :FTS_INDEX_Q,
    "r" => :FTS_INDEX_R,
    "s" => :FTS_INDEX_S,
    "t" => :FTS_INDEX_T,
    "u" => :FTS_INDEX_U,
    "w" => :FTS_INDEX_W,
    "x" => :FTS_INDEX_X,
    "y" => :FTS_INDEX_Y,
    "z" => :FTS_INDEX_Z,
    "other" => :FTS_INDEX_OTHER
  }
  def create() do
    node_list = [node()]

    :ok =
      Enum.each(@letter_tables, fn {_letter, table_name} ->
        result =
          :mnesia.create_table(table_name,
            attributes: [:id, :attr, :freq],
            disc_copies: node_list,
            type: :bag
          )

        case result do
          {:atomic, :ok} ->
            :ok

          {:aborted, {:already_exists, _table_name}} ->
            :ok
        end
      end)
  end

  def update(_col, nil, _id), do: :ok

  def update(col, val, id) when is_list(val), do: update(col, Enum.join(val, " "), id)

  def update(col, val, id) when is_bitstring(val) do
    val
    |> String.graphemes()
    |> Enum.map(&String.downcase/1)
    |> Enum.frequencies()
    |> Enum.each(fn
      {" ", _} ->
        :ok

      {letter, freq} ->
        :mnesia.write({get_table(letter), id, col, freq})
    end)
  end

  def get_candidates_for_term(term) do
    letters =
      term
      |> String.graphemes()
      |> Enum.map(&String.downcase/1)

    term_freqs = Enum.frequencies(letters)

    {max_l, max_freq} = Enum.max_by(term_freqs, fn {_l, f} -> f end)

    table = get_table(max_l)

    :mnesia.dirty_select(table, [
      {{table, :"$1", :"$2", :"$3"}, [{:>=, :"$3", max_freq}], [:"$$"]}
    ])
    |> Enum.group_by(fn [id, _attr, _freq] -> id end, fn [_id, attr, _freq] -> attr end)

    # {smallest_table, smallest_letter, _} =
    #   term_freqs
    #   |> Enum.map(fn {l, _freq} ->
    #     t = get_table(l)
    #     {t, l, get_table_items_count(t)}
    #   end)
    #   |> Enum.min_by(&elem(&1, 1))

    # smallest_table
    # |> :mnesia.dirty_select([
    #   {{smallest_table, :"$1", :"$2"}, [{:>=, :"$2", term_freqs[smallest_letter]}], [:"$1"]}
    # ])
  end

  def clear_tables() do
    Enum.each(@letter_tables, fn {_l, t} ->
      {:atomic, :ok} = :mnesia.clear_table(t)
    end)
  end

  def get_tables(), do: Enum.map(@letter_tables, fn {_l, t} -> t end)

  defp get_table(letter), do: @letter_tables[letter] || @letter_tables["other"]
end
