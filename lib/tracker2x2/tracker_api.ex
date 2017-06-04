defmodule Tracker2x2.TrackerApi do
  @moduledoc """
    Defining the behaviour of the Tracker API
  """
  @callback get_epics(project_id :: String.t, tracker_token :: String.t) :: {atom, []}
end
