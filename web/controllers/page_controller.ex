defmodule Tracker2x2.PageController do
  use Tracker2x2.Web, :controller
  plug :authenticate when action in [:index]

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def authenticate(conn, _opts) do
    if conn.assigns.current_user do
      redirect_to = case conn.assigns.current_user.tracker_token do
        nil -> :edit
        _ -> :index
      end
      conn
      |> redirect(to: elm_path(conn, redirect_to))
      |> halt()
    else
      conn
    end
  end
end
