defmodule Tracker2x2.Auth do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> assign(:current_user, get_session(conn, :current_user))
  end
end
