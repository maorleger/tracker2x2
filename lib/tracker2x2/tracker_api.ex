defmodule Tracker2x2.TrackerApi do
  @moduledoc """
    Defining the behaviour of the Tracker API
  """

  # credo:disable-for-next-line Credo.Check.Readability.MaxLineLength
  @callback get_epics(project_id :: String.t, tracker_token :: String.t) :: {atom, %{status_code: integer, response_body: %{}}}

  # credo:disable-for-next-line Credo.Check.Readability.MaxLineLength
  @callback get_stories(project_id :: String.t, epic :: String.t, tracker_token :: String.t) :: {atom, %{}}
end
