defmodule Tracker2x2.TrackerApi.HTTPClient do
  @behaviour Tracker2x2.TrackerApi
  @moduledoc """
    The wrapper around the real Pivotal Tracker API
  """

  def get_epics(project_id, tracker_token) do
    epics_url = "https://www.pivotaltracker.com/services/v5/projects/#{project_id}/epics"
    response = HTTPotion.get epics_url, [headers: [Accepts: "application/json", "X-TrackerToken": tracker_token]]

    process_response(response, fn(response_body) ->
      build_map = fn(labels) -> Map.put(%{}, :epics, labels) end

      response_body
      |> Poison.decode!
      |> Enum.map(fn(item) ->
        item
        |> Map.get("label")
        |> Map.get("name")
      end)
      |> build_map.()
    end)
  end

  defp process_response(response, callback) do
    case response.status_code do
      200 ->
        {:ok, callback.(response.body)}
      code ->
        {:error, %{status_code: code, response_body: Poison.decode!(response.body)}}
    end
  end
end
