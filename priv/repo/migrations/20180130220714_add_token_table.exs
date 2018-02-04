defmodule Evixir.Repo.Migrations.AddTokenTable do
  use Ecto.Migration

  def change do
    create table(:tokens) do
      add :channel_id, :string, size: 64
      add :access_token, :string
      add :expires_at, :integer
      add :refresh_token, :string
      add :token_type, :string
    end

    create unique_index(:tokens, [:channel_id])
  end
end
