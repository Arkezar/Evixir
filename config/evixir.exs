use Mix.Config

config :nostrum, token: "NDA2ODQ2NzYzMDMxMzMwODIw.DU8vbg.gZTRH_wVPUGzNDsPHInFTnHwZ5E", num_shards: :auto
config :oauth2, client_id: "<cid>", client_secret: "<csec>", redirect_uri: "http://localhost:8080/auth-callback"
config :evixir, ecto_repos: [Evixir.Repo]
config :evixir, Evixir.Repo,
    adapter: Ecto.Adapters.MySQL,
    database: "<db>",
    username: "<dbuser>",
    password: "<dbpass>",
    hostname: "<host>",
    port: "3306"