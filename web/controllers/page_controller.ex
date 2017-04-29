defmodule Tracker2x2.PageController do
  use Tracker2x2.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
