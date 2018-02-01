defmodule Evixir.Router do
    import Plug.Conn
    use Plug.Router

    plug(:match)
    plug(:dispatch)

    get("/", do: handle_auth_redirect(conn))
    get("/auth-callback", do: handle_callback(conn))
    match(_, do: send_resp(conn, 404, "404"))

    def handle_auth_redirect(conn) do
        conn = fetch_query_params(conn)
        conn |> put_resp_header("location", Evixir.ESI.Authentication.auth(conn.params)) |> send_resp(301, "")
    end

    def handle_callback(conn) do
        conn = fetch_query_params(conn)
        token = Evixir.ESI.Authentication.callback(conn.params)
        send_resp(conn, 200, token)
    end
end