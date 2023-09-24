defmodule RinhaRepo.Migrations.AddPessoasTable do
  use Ecto.Migration

  def change do
    create table("pessoas", primary_key: false) do
      add :id, :uuid, primary_key: true
      add :apelido, :string
      add :nome, :string
      add :nascimento, :string
      add :stack, :text
    end

    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"

    execute """
    CREATE INDEX pessoas_fts_idx ON pessoas USING GIST ((apelido || ' ' || nome || ' ' || stack) gist_trgm_ops(siglen=1024));
    """
  end
end
