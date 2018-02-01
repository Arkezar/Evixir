defmodule Evixir.ESI.Authentication do
    use OAuth2.Strategy
    require Ecto.Query

    def client do
        OAuth2.Client.new([
            client_id: Application.get_env(:oauth2, :client_id),
            client_secret: Application.get_env(:oauth2, :client_secret),
            redirect_uri: Application.get_env(:oauth2, :redirect_uri),
            site: "https://login.eveonline.com"
          ])
    end

    def auth(params) do
        OAuth2.Client.authorize_url!(client, [scope: "esi-killmails.read_corporation_killmails.v1", state: params["channel"]])
    end

    def auth_header do
        "Basic " <> Base.encode64(Application.get_env(:oauth2, :client_id) <> ":" <> Application.get_env(:oauth2, :client_secret))
    end

    def callback(params) do
        OAuth2.Client.get_token(client, [code: params["code"], grant_type: "authorization_code"], [{"Authorization", auth_header()}]) |> handle_callback(params["state"])
    end

    def handle_callback({:ok, data}, state) do
        new_auth_token = %Evixir.ESI.Token{
            channel_id: state,
            access_token: data.token.access_token,
            expires_at: data.token.expires_at,
            refresh_token: data.token.refresh_token,
            token_type: data.token.token_type
        }
        Evixir.Repo.insert(new_auth_token)
        "Your are authenticated. You may close this page now."
    end

    def handle_callback({:error, data}, state) do
        "Something went wrong :("
    end

    def refresh(channelid) do
        token_record = Evixir.ESI.Token |> Ecto.Query.where(channel_id: ^channelid) |> Evixir.Repo.one
        OAuth2.Client.get_token(client, [refresh_token: token_record.refresh_token, grant_type: "refresh_token"], [{"Authorization", auth_header()}]) |> handle_refresh(token_record)
    end

    def handle_refresh({:ok, data}, token_record) do
        change = Evixir.ESI.Token.changeset(token_record, %{
            access_token: data.token.access_token,
            expires_at: data.token.expires_at,
            refresh_token: data.token.refresh_token,
            token_type: data.token.token_type
        })
        Evixir.Repo.update(change)
    end
end