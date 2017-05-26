defmodule Tracker2x2.AppController do
  use Tracker2x2.Web, :controller
  alias Tracker2x2.User

  plug :authenticate when action in [:index, :edit, :update]
  plug :ensure_token when action in [:index]

  def index(conn, _params, current_user) do
    conn
    |> render("index.html")
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
      %User{tracker_token: nil} ->
        conn
        |> redirect(to: page_path(conn, :index))
        |> halt()
      _ ->
        conn
        |> assign(:token, Phoenix.Token.sign(conn, "user", conn.assigns.current_user.id))
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end
end
