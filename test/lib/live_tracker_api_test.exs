defmodule Tracker2x2.LiveTrackerApiTest do
  use Tracker2x2.ConnCase, async: true

  alias Tracker2x2.TrackerApi.HTTPClient

  @tracker_token System.get_env("TRACKER_API_TOKEN")
  @project_id System.get_env("TRACKER_TEST_PROJECT_ID")

  test "happy path" do
    {:ok, data} = HTTPClient.get_epics(@project_id, @tracker_token)
    assert %{response_body: [epic | _epics]} = data

    {:ok, data} = HTTPClient.get_stories(@project_id, epic, @tracker_token)
    assert %{response_body: [%{"description" => _description, "id" => _id, "name" => _name} | _stories]} = data
  end

  test "get_epics unfound resource" do
    {:error, %{response_body: _response_body, status_code: 404}} = HTTPClient.get_epics(0, @tracker_token)
  end

  test "get_epics authorization" do
    {:error, %{response_body: _response_body, status_code: 403}} = HTTPClient.get_epics(2, @tracker_token)
  end
end
