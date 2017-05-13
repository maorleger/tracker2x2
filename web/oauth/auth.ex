defmodule Tracker2x2.Auth do
  import Plug.Conn
  alias Tracker2x2.Repo
  alias Tracker2x2.User

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
      case Tracker2x2.Repo.get_by(Tracker2x2.User, email: email) do
        nil -> %User{email: email}
        user -> user
      end
      |> Tracker2x2.User.changeset
      |> Tracker2x2.Repo.insert_or_update
    end
  end
end
