defmodule Tracker2x2.TokenController do
  use Tracker2x2.Web, :controller
  alias Tracker2x2.User

  def create(conn, _params, current_user) do
    changeset = User.changeset(current_user)

    conn
    |> render("create.html", changeset: changeset)
  end

  
  def edit(conn, _params, current_user) do
    changeset = User.changeset(current_user)

    conn
    |> render("edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}, current_user) do
    changeset = User.changeset(current_user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> assign(:current_user, user)
        |> redirect(to: page_path(conn, :index))
      {:error, _} ->
        conn
        |> render("edit.html")
    end
  end
end
