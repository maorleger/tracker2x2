defmodule Tracker2x2.ApiAuth do
  import Plug.Conn
  alias Tracker2x2.Repo
  alias Tracker2x2.User

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{params: %{"user_id" => user_id, "token" => token}} = conn, _opts) do
    with {:ok, token_user_id} <- Phoenix.Token.verify(conn, "user", token),
         {:ok, _} <- verify_token_user(token_user_id, user_id)
    do
      conn
      |> assign(:tracker_token, get_tracker_token(token_user_id))
    else
      _ ->send_401(conn)
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

  defp verify_token_user(token_user_id, user_id) do
    if "#{token_user_id}" == "#{user_id}" do
      {:ok, user_id}
    else
      {:error, "user id does not match the token"}
    end
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
