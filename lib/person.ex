defmodule Person do
  use Ecto.Schema
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "pessoas" do
    field :apelido, :string
    field :nome, :string
    field :nascimento, :string
    field :stack, :string
  end

  def get_str_attr() do
    [
      "apelido",
      "nome",
      "nascimento",
      "stack"
    ]
  end

  def insert(params) do
    if Cache.exists?({:apelido, params.apelido}) do
      {:error, :already_taken}
    else
      {:ok, new_p} =
        %Person{
          apelido: params.apelido,
          nome: params.nome,
          nascimento: params.nascimento,
          stack: handle_stack_in(params[:stack])
        }
        |> RinhaRepo.insert()

      cached_p = Map.put(new_p, :stack, handle_stack_out(new_p.stack))

      # apelido is always on the right node to cache
      true = Cache.write({:apelido, new_p.apelido}, nil)

      # id might not be on the right node for cache so we need to check
      true =
        new_p.id
        |> HttpServer.term_to_node()
        |> :rpc.call(Cache, :write, [
          {:id, new_p.id},
          Map.take(cached_p, [:id, :apelido, :nome, :nascimento, :stack])
        ])

      {:ok, new_p.id}
    end
  end

  def fetch(id) do
    # The cache is guarenteed to be consistent because
    # of the phash trick on the http layer
    # so we do not need to query the DB
    case Cache.read({:id, id}) do
      nil ->
        {:error, :not_found}

      val ->
        {:ok, val}
    end
  end

  def search(term) do
    {:ok, result} =
      RinhaRepo.query("""
      select id::varchar, apelido, nome, nascimento, stack
      from pessoas where
      (apelido || ' ' || nome || ' ' || stack) ilike '%#{term}%'
      limit 50
      """)

    cols = Enum.map(result.columns, &String.to_existing_atom/1)

    Enum.map(result.rows, fn e -> Enum.zip(cols, e) |> Map.new() end)
    |> Enum.map(fn p -> Map.replace(p, :stack, handle_stack_out(p.stack)) end)
  end

  def count() do
    {:ok, result} = RinhaRepo.query("select count(1) from pessoas")
    result.rows |> List.first() |> List.first()
  end

  defp handle_stack_out(""), do: []
  defp handle_stack_out(string), do: String.split(string, " ")

  defp handle_stack_in(nil), do: ""
  defp handle_stack_in(list), do: Enum.join(list, " ")
end
