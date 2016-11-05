defmodule Chat.PageView do
  use Chat.Web, :view

  def current_username(conn) do
    Map.get(conn.params, "name", "anonymous")
  end
end
