defmodule Test do
  @letters ["a", "b", "c", "d", "e", "f", "g", "h"]
  def insert_many(qtd) do
    Enum.map(1..qtd, fn i ->
      input = %{
        nome: Enum.map(1..100, fn _ -> Enum.random(@letters) end) |> Enum.join(),
        apelido: (Enum.map(1..31, fn _ -> Enum.random(@letters) end) |> Enum.join()) <> "#{i}",
        stack: ["elixir", "node", "c#", "asdsad", "adfadsfadaf", "adfdsfasfdsaf", "asfdaffisdj"],
        nascimento: "1995-09-12"
      }

      {:ok, _} =
        input.apelido
        |> HttpServer.term_to_node()
        |> :rpc.call(Person, :insert, [input])
    end)
  end
end
