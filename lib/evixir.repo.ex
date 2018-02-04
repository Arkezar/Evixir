defmodule Evixir.Repo do
    use Ecto.Repo,
    otp_app: :evixir
end

defmodule Evixir.ESI.Token do
    use Ecto.Schema

    schema "tokens" do
        field :channel_id
        field :access_token
        field :expires_at, :integer
        field :refresh_token
        field :token_type
        has_one :channel, Evixir.ESI.Channel
    end

    def changeset(token, params \\ %{}) do
        token
        |> Ecto.Changeset.cast(params, [:access_token, :expires_at, :refresh_token, :token_type])
        |> Ecto.Changeset.validate_required([:access_token, :expires_at, :refresh_token, :token_type])
    end
end

defmodule Evixir.ESI.Channel do
    use Ecto.Schema

    schema "channels" do
        field :channel_id
        field :corporation_id, :integer
        field :last_killmail, :integer
        belongs_to :token, Evixir.ESI.Token
    end

    def changeset(channel, params \\ %{}) do
        channel
        |> Ecto.Changeset.cast(params, [:last_killmail])
        |> Ecto.Changeset.unique_constraint(:channel_id)
    end
end