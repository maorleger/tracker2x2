defmodule Tracker2x2.TrackerApi.InMemory do
  @behaviour Tracker2x2.TrackerApi
  @moduledoc """
    An in memory mock of the Pivotal Tracker API
  """
  def get_epics(nil, _tracker_token) do
    {:error,
      %{"code" => "unfound_resource",
        "error" => "The object you tried to access could not be found.  It may have been removed by another user, you may be using the ID of another object type, or you may be trying to access a sub-resource at the wrong point in a tree.",
        "kind" => "error"}}
  end

  def get_epics(_project_id, nil) do
    {:error,
      %{"code" => "invalid_authentication",
        "error" => "Invalid authentication credentials were presented.",
        "kind" => "error"}}
  end

  def get_epics(_project_id, _tracker_token) do
    {:ok, ["Epic1", "Epic2", "Epic3"]}
  end

end
