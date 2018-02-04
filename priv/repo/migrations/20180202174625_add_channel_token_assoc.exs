defmodule Evixir.Repo.Migrations.AddChannelTokenAssoc do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :token_id, references(:tokens)
    end
  end
end
