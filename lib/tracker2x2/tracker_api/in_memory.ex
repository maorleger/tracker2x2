defmodule Tracker2x2.TrackerApi.InMemory do
  @behaviour Tracker2x2.TrackerApi
  @moduledoc """
    An in memory mock of the Pivotal Tracker API
  """
  def get_epics(nil, _tracker_token) do
    {:error,
      %{status_code: 400, response_body: %{"code" => "unfound_resource",
        "error" => "The object you tried to access could not be found.  It may have been removed by another user, you may be using the ID of another object type, or you may be trying to access a sub-resource at the wrong point in a tree.",
        "kind" => "error"}}}
  end

  def get_epics(_project_id, nil) do
    {:error,
      %{status_code: 400, response_body: %{"code" => "invalid_authentication",
        "error" => "Invalid authentication credentials were presented.",
        "kind" => "error"}}}
  end

  def get_epics(project_id, tracker_token) do
    if project_id == "123" do
      {:ok, %{response_body: ["Epic1", "Epic2", "Epic3"]}}
    else
      get_epics(nil, tracker_token)
    end
  end

  def get_stories(nil, _epic, tracker_token) do
    get_epics(nil, tracker_token)
  end

  def get_stories(project_id, epic, tracker_token) do
    if project_id == "123" do
      {:ok, %{response_body: [
        %{id: "1", name: "Must do the things", description: nil},
        %{id: "2", name: "With description", description: "I have it!"},
        %{id: "3", name: "Some other story", description: nil}
      ]}}
    else
      get_stories(nil, epic, tracker_token)
    end
  end

end
