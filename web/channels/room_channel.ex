defmodule Chat.RoomChannel do
  use Chat.Web, :channel
  alias Chat.Presence

  def join("room:lobby", _msg, socket) do
    send self(), :after_join
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.username, %{device: "browser"})
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end
end
