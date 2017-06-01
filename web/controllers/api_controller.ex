defmodule Tracker2x2.ApiController do
  use Tracker2x2.Web, :controller

  def test(conn, _params) do
    if conn.assigns.tracker_token do
      render(conn, "test.json")
    else
      conn
      |> send_resp(404, "not found")
      |> halt()
    end
  end
end
