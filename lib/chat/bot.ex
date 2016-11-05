defmodule Chat.Bot do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(state) do
    ping
    {:ok, state}
  end

  def handle_info(:ping, state) do
    Chat.Endpoint.broadcast(
      "room:lobby",
      "new_msg",
      %{time: "", username: "BOT", body: "ping"}
    )
    ping
    {:noreply, state}
  end

  defp ping do
    Process.send_after(self(), :ping, 10000)
  end
end
