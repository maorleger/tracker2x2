defmodule Tracker2x2.AppController do
  use Tracker2x2.Web, :controller
  plug :authenticate when action in [:index, :edit, :update]
  plug :ensure_token when action in [:index]

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def edit(conn, _params) do
    changeset = Tracker2x2.User.changeset(conn.assigns.current_user)

    conn
    |> render("edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_changeset}) do
    changeset = Tracker2x2.User.changeset(conn.assigns.current_user, user_changeset)

    case Repo.update(changeset) do
      {:ok, user} -> 
        conn
        |> assign(:current_user, user)
        |> redirect(to: page_path(conn, :index))
      {:error, new_changeset} ->
        conn
        |> render("index.html")
    end
  end

  def authenticate(conn, _opts) do
    conn = case conn.assigns.current_user do
      nil -> 
        conn
        |> put_flash(:error, "Please login to continue")
        |> redirect(to: page_path(conn, :index))
        |> halt()
      _ -> 
        conn
    end
  end

  def ensure_token(conn, _opts) do
    conn = case conn.assigns.current_user do
      %Tracker2x2.User{tracker_token: nil} ->
        conn
        |> redirect(to: page_path(conn, :index))
        |> halt()
      _ ->
        conn
    end
  end
end
