defmodule Tracker2x2.ApiAuth do
  import Plug.Conn
  alias Tracker2x2.Repo
  alias Tracker2x2.User

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{params: %{"user_id" => user_id, "token" => token}} = conn, _opts) do
    case Phoenix.Token.verify(conn, "user", token) do
      {:ok, _} ->
        conn
        |> assign(:tracker_token, get_tracker_token(user_id))
      {:error, _} ->
        send_401(conn)
    end
  end

  def call(conn, _opts) do
    send_401(conn)
  end

  defp send_401(conn) do
    conn
    |> send_resp(401, "unauthorized")
    |> halt()
  end

  defp get_tracker_token(user_id) do
    user = Repo.get(User, user_id)
    if user do
      user.tracker_token
    else
      nil
    end
  end

end