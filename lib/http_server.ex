defmodule HttpServer do
  use Plug.Router

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  def rand_node() do
    [:this, :visible]
    |> Node.list()
    |> Enum.random()
  end

  def term_to_node(term) do
    nodes = Enum.sort(Node.list([:this, :visible]))
    node_index = :erlang.phash2(term, length(nodes))
    Enum.at(nodes, node_index)
  end

  def rpc(Person, :insert, [body]),
    do: body.apelido |> term_to_node() |> :rpc.call(Person, :insert, [body])

  def rpc(Person, :search, [val]),
    do: val |> term_to_node() |> :rpc.call(Person, :search, [val])

  def rpc(Person, :fetch, [id]),
    do: id |> term_to_node() |> :rpc.call(Person, :fetch, [id])

  def rpc(Person, :count),
    do: rand_node() |> :rpc.call(Person, :count, [])

  post "/pessoas" do
    body =
      conn.body_params
      |> Map.take(Person.get_str_attr())
      |> Enum.map(fn {k, v} -> {String.to_existing_atom(k), v} end)
      |> Map.new()

    required = [:apelido, :nome, :nascimento]

    body_rules = %{
      apelido: [
        fn v -> is_bitstring(v) end,
        fn v -> String.length(v) <= 32 end
      ],
      nome: [
        fn v -> is_bitstring(v) end,
        fn v -> String.length(v) <= 100 end
      ],
      nascimento: [
        fn v -> is_bitstring(v) end,
        fn v -> match?({:ok, _}, Date.from_iso8601(v)) end
      ],
      stack: [
        fn v -> is_nil(v) || is_list(v) end,
        fn v -> Enum.all?(v || [], &is_bitstring/1) end
      ]
    }

    cond do
      not Enum.all?(required, fn k -> Map.get(body, k) end) ->
        send_resp(conn, 422, "")

      not Enum.all?(body_rules, fn {k, rules} -> Enum.all?(rules, fn f -> f.(body[k]) end) end) ->
        send_resp(conn, 400, "")

      true ->
        case rpc(Person, :insert, [body]) do
          {:ok, id} ->
            conn
            |> put_resp_header("Location", "/pessoas/#{id}")
            |> send_resp(201, id)

          {:error, :already_taken} ->
            send_resp(conn, 422, "already taken")

          err ->
            send_resp(conn, 500, "unexpected error #{inspect(err)}")
        end
    end
  end

  get "/pessoas" do
    conn = fetch_query_params(conn)

    case conn.query_params do
      %{"t" => val} ->
        data = rpc(Person, :search, [val])

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(data))

      _ ->
        send_resp(conn, 400, "")
    end
  end

  get "/pessoas/:person_id" do
    case rpc(Person, :fetch, [conn.params["person_id"]]) do
      {:ok, data} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(data))

      {:error, :not_found} ->
        send_resp(conn, 404, "")
    end
  end

  get "/contagem-pessoas" do
    send_resp(conn, 200, rpc(Person, :count) |> Integer.to_string())
  end

  match _ do
    send_resp(conn, 404, "route not found")
  end
end
