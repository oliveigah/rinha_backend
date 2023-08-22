defmodule RinhaBackendTest do
  use ExUnit.Case, async: true

  setup do
    Cache.clear()
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(RinhaRepo)
  end

  test "success insert and fetch" do
    input = %{
      nome: "Gabriel",
      apelido: "oliveigah",
      stack: ["elixir", "node", "c#"],
      nascimento: "1995-09-12"
    }

    assert {:ok, id} = Person.insert(input)
    assert {:ok, data} = Person.fetch(id)
    assert data.apelido == input.apelido

    assert {:error, :already_taken} = Person.insert(input)
  end

  test "full text search" do
    [p1, p2, p3, p4, p5] =
      [
        %{
          nome: "Gabriel",
          apelido: "oliveigah",
          stack: ["elixir", "node", "c#"],
          nascimento: "1995-09-12"
        },
        %{
          nome: "Raquel",
          apelido: "raquelub",
          stack: ["teste", "some_other_stack"],
          nascimento: "1995-09-12"
        },
        %{
          nome: "Joah",
          apelido: "joaodopao",
          stack: ["c#", "joa", "test"],
          nascimento: "1995-09-12"
        },
        %{
          nome: "Lucas",
          apelido: "lucasal",
          stack: ["node", "react", "joah", "elixir"],
          nascimento: "1995-09-12"
        },
        %{
          nome: "John Doe",
          apelido: "someone",
          nascimento: "1995-09-12"
        }
      ]
      |> Enum.map(fn input ->
        assert {:ok, id} = Person.insert(input)
        assert {:ok, p} = Person.fetch(id)
        p
      end)

    assert result = Person.search("no_exist")
    assert length(result) == 0

    assert result = Person.search("oliveigah")
    assert length(result) == 1
    assert p1 in result

    assert result = Person.search("ah")
    assert length(result) == 3
    assert p1 in result
    assert p3 in result
    assert p4 in result

    assert result = Person.search("el")
    assert length(result) == 3
    assert p1 in result
    assert p2 in result
    assert p4 in result

    assert result = Person.search("a")
    assert length(result) == 4
    assert p1 in result
    assert p2 in result
    assert p4 in result
    assert p4 in result

    assert result = Person.search("some_other_stack")
    assert length(result) == 1
    assert p2 in result

    assert result = Person.search("someone")
    assert length(result) == 1
    assert p5 in result
  end
end
