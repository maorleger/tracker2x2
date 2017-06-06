defmodule Tracker2x2.TrackerApiTest do
  use Tracker2x2.ConnCase, async: true

  @tracker_api Application.get_env(:tracker2x2, :tracker_api)

  test "happy path" do
    assert @tracker_api.get_epics("123", "token") == {:ok, %{epics: ["Epic1", "Epic2", "Epic3"]}}
  end

  test "Unfound project" do
    assert @tracker_api.get_epics(nil, "token") == {:error,
      %{status_code: 400, response_body: %{"code" => "unfound_resource",
        "error" => "The object you tried to access could not be found.  It may have been removed by another user, you may be using the ID of another object type, or you may be trying to access a sub-resource at the wrong point in a tree.",
        "kind" => "error"}}}
  end

  test "Invalid tracker token" do
    assert @tracker_api.get_epics("123", nil) == {:error,
      %{status_code: 400, response_body: %{"code" => "invalid_authentication",
        "error" => "Invalid authentication credentials were presented.",
        "kind" => "error"}}}
  end

end
