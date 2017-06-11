defmodule Tracker2x2.AppController do
  use Tracker2x2.Web, :controller
  alias Tracker2x2.User
  alias Phoenix.Token

  plug :authenticate when action in [:index, :edit, :update]
  plug :ensure_token when action in [:index]

  def index(conn, _params, _current_user) do
    conn
    |> render("index.html")
  end

  def authenticate(conn, _opts) do
    case conn.assigns.current_user do
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
    case conn.assigns.current_user do
      %User{tracker_token: nil} ->
        conn
        |> redirect(to: page_path(conn, :index))
        |> halt()
      _ ->
        conn
        |> assign(
          :token,
          Token.sign(conn, System.get_env("APP_SALT"),
          conn.assigns.current_user.id))
    end
  end

  def action(conn, _) do
    apply(
      __MODULE__,
      action_name(conn),
      [conn, conn.params, conn.assigns.current_user]
    )
  end
end
