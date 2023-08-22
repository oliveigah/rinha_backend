defmodule RinhaRepo.Migrations.AddPessoasTable do
  use Ecto.Migration

  def change do
    create table("pessoas", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :apelido, :string
      add :nome, :string
      add :nascimento, :string
      add :stack, {:array, :string}
      add :fts_col, :text
    end

    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"

    execute """
    CREATE INDEX pessoas_fts_idx ON pessoas USING GIST (fts_col gist_trgm_ops);
    """
  end
end
