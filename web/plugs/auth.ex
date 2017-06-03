defmodule Tracker2x2.Auth do
  @moduledoc """
    Auth plug, which will assign the current user using their oauth email
  """
  import Plug.Conn
  alias Tracker2x2.{Repo, User}

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    conn
    |> assign(:current_user, get_or_create_user(conn))
  end

  defp get_or_create_user(conn) do
    email = get_session(conn, :oauth_email)
    if email do
      user_changeset = case Repo.get_by(Tracker2x2.User, email: email) do
        nil -> %User{email: email}
        user -> user
      end

      {:ok, user} =
        user_changeset
        |> User.changeset
        |> Repo.insert_or_update

      user
    end
  end
end
