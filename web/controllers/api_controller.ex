defmodule Tracker2x2.ApiController do
  use Tracker2x2.Web, :controller
  plug :authenticate when action in [:test, :epics, :stories]

  @tracker_api Application.get_env(:tracker2x2, :tracker_api)

  def test(conn, _params) do
    render(conn, "test.json")
  end

  def epics(conn, %{"project_id" => project_id}) do
    case @tracker_api.get_epics(project_id, conn.assigns.tracker_token) do
      {:ok, %{response_body: epics}} ->
        render(conn, "epics.json", %{epics: epics})
      {:error, %{status_code: status_code, response_body: tracker_error}} ->
        conn
        |> put_resp_header("content-type", "application/json; charset=utf-8")
        |> send_resp(status_code, Poison.encode!(tracker_error))
    end
  end

  def stories(conn, %{"project_id" => project_id, "epic" => epic}) do
    case @tracker_api.get_stories(project_id, epic, conn.assigns.tracker_token) do
      {:ok, %{response_body: stories}} ->
        render(conn, "stories.json", %{stories: stories})
      {:error, %{status_code: status_code, response_body: tracker_error}} ->
        conn
        |> put_resp_header("content-type", "application/json; charset=utf-8")
        |> send_resp(status_code, Poison.encode!(tracker_error))
    end
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
