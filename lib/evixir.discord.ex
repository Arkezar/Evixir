defmodule Evixir.Discord do
    use Nostrum.Consumer
    alias Nostrum.Api
    require Logger
  
    def start_link do
      Consumer.start_link(__MODULE__)
    end
  
    def handle_event({:MESSAGE_CREATE, {msg}, ws_state}, state) do
      unless byte_size(msg.content) == 0 do
        command = String.split(msg.content)
        case hd(command) do
          <<"!" :: binary, "help" :: binary>> ->
            Api.create_message(msg.channel_id, "Available commands:\n!auth - authorize this channel to post recent killmails (only server owner)\n!pc <item name> - check item price in Jita\n!ping - pong")
          <<"!" :: binary, "auth" :: binary>> ->
            Api.create_message(msg.channel_id, "Visit https://evixir.metacode.pl/?channel=" <> to_string(msg.channel_id) <> " to authenticate with this channel.")
          <<"!" :: binary, "ping" :: binary>> ->
            Api.create_message(msg.channel_id, "Warp drive active!")
          <<"!" :: binary, "pc" :: binary>> ->
            Api.create_message(msg.channel_id, Evixir.ESI.Market.check_price(Enum.join(tl(command), " ")))
          _ ->
            :ignore
        end
      end
      {:ok, state}
    end
  
    # Default event handler, if you don't include this, your consumer WILL crash if
    # you don't have a method definition for each event type.
    def handle_event(_, state) do
      {:ok, state}
    end
  end