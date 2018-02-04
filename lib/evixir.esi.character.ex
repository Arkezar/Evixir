defmodule Evixir.ESI.Character do
    def get_character_info(char_id) do
        HTTPotion.get("https://esi.tech.ccp.is/latest/characters/" <> to_string(char_id) <> "/", headers: ["X-User-Agent": "Evixir"]).body |> Poison.decode!
    end
end