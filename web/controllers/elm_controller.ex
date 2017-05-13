defmodule Tracker2x2.ElmController do
  use Tracker2x2.Web, :controller
  plug :authenticate when action in [:index]

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "Please login to continue")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end
end
