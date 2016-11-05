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

  def handle_in("new_msg", %{"username" => username, "body" => body}, socket) do
    time = DateTime.utc_now |> format_time
    case handle_message(body) do
      {:broadcast, msg} ->
        broadcast! socket, "new_msg", %{time: time, username: username, body: msg}
      _ ->
        :ok
    end
    {:noreply, socket}
  end

  defp handle_message("/img " <> url) do
    {:broadcast, "<img src='#{url}' />"}
  end

  defp handle_message("/flip_table") do
    {:broadcast, "(╯°□°）╯︵ ┻━┻"}
  end

  defp handle_message("/shrug") do
    {:broadcast, " ¯\\_(ツ)_/¯"}
  end

  defp handle_message(msg) do
    {:broadcast, msg}
  end

  defp format_time(%DateTime{hour: hour, minute: minute}) do
    "#{format_number(hour)}:#{format_number(minute)}"
  end

  defp format_number(number) do
    number |> Integer.to_string |> String.pad_leading(2, "0")
  end
end
