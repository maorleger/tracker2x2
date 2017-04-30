defmodule Tracker2x2.PageController do
  use Tracker2x2.Web, :controller
  require Logger

  def index(conn, _params) do
    # TODO: there must be a way to reload this guy!!!!
    case Coherence.current_user(conn) do
      nil -> 
        token = nil
      user -> token = Repo.get!(Tracker2x2.User, Coherence.current_user(conn).id).token
    end
    render conn, "index.html", token: token
  end

  def update_token(conn, %{"user_id" => user_id, "token" => token}) do
    user = Repo.get!(Tracker2x2.User, user_id)
    changeset = Tracker2x2.User.changeset(Repo.get!(Tracker2x2.User, user_id), %{token: token})
    Repo.update(changeset)
    json(conn, %{body: user_id})
  end
end
