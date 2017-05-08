defmodule Tracker2x2.PageControllerTest do
  use Tracker2x2.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Sign in with Google"
  end
end
