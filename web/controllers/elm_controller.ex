defmodule Tracker2x2.ElmController do
  use Tracker2x2.Web, :controller
  plug :authenticate when action in [:index]

  def index(conn, _params) do
    conn
    |> assign(:current_user, get_session(conn, :current_user))
    |> render("index.html")
  end
  
  defp authenticate(conn, _opts) do
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
