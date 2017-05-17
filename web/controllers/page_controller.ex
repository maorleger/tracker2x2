defmodule Tracker2x2.PageController do
  use Tracker2x2.Web, :controller
  plug :authenticate when action in [:index]

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn
      |> redirect(to: elm_path(conn, :index))
      |> halt()
    else
      conn
    end
  end
end
