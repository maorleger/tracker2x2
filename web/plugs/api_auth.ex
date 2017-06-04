defmodule Tracker2x2.ApiAuth do
  @moduledoc """
    Provides a plug to authenticate and grab a 
    Pivotal Tracker token for a given user
  """

  import Plug.Conn
  alias Tracker2x2.Repo
  alias Tracker2x2.User
  alias Phoenix.Token

  def init(opts) do
    opts
  end

  def call(%Plug.Conn{params: %{"user_id" => user_id}} = conn, _opts) do
    with {:ok, token_user_id} <- Token.verify(conn, System.get_env("APP_SALT"), get_header_token(conn)),
         {:ok, _} <- verify_token_user(token_user_id, user_id)
    do
      conn
      |> assign(:tracker_token, get_tracker_token(token_user_id))
    else
      _ -> send_401(conn)
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
    with {:ok, token_user_id} <- safe_to_int(token_user_id),
         {:ok, user_id} <- safe_to_int(user_id),
    do:
      compare_ids(token_user_id, user_id)

  end

  defp compare_ids(token_user_id, user_id) do
    if token_user_id == user_id do
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

  defp get_header_token(conn) do
    case get_req_header(conn, "token") do
      [token] -> token
      _ -> nil
    end
  end

  defp safe_to_int(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> {:error, "could not parse an id"}
    end
  end

  defp safe_to_int(integer) when is_integer(integer) do
    {:ok, integer}
  end
end
