defmodule Tracker2x2.ApiController do
  use Tracker2x2.Web, :controller
  plug :authenticate when action in [:test, :epics]

  @tracker_api Application.get_env(:tracker2x2, :tracker_api)

  def test(conn, _params) do
    render(conn, "test.json")
  end

  def epics(conn, %{"project_id" => project_id}) do
    {:ok, epics} = @tracker_api.get_epics(project_id, conn.assigns.tracker_token)
    render(conn, "epics.json", %{epics: epics})
  end

  defp authenticate(conn, _opts) do
    case conn.assigns.tracker_token do
      nil ->
        conn
        |> send_resp(404, "not found")
        |> halt()
      _ ->
        conn
    end
  end
end
