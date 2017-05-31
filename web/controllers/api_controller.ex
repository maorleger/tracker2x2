defmodule Tracker2x2.ApiController do
  use Tracker2x2.Web, :controller
  alias Tracker2x2.User

  def test(conn, _params) do
    render(conn, "test.json")
  end
end
