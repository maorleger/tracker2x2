defmodule Tracker2x2.ApiView do
  use Tracker2x2.Web, :view

  def render("test.json", _params) do
    "Success"
  end
end
