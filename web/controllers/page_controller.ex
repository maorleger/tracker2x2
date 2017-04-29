defmodule Tracker2x2.PageController do
  use Tracker2x2.Web, :controller

  def index(conn, _params) do
    render conn, "index.html", user: %{id: 1, token: 'SomeToken'}
  end
end
