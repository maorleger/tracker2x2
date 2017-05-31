defmodule Tracker2x2.ApiAuth do
  import Plug.Conn
  alias Tracker2x2.Repo
  alias Tracker2x2.User

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{params: %{"user_id" => user_id, "token" => token}} = conn, _opts) do
    conn
    |> assign(:tracker_token, get_tracker_token(user_id, token))
  end

  defp get_tracker_token(user_id, token) do
    user = Repo.get(User, user_id)
    user.tracker_token
  end

end
