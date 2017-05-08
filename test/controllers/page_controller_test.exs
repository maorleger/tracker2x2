defmodule Tracker2x2.PageControllerTest do
  use Tracker2x2.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    response = html_response(conn, 200) 
    assert response =~ "Sign in with Google"
    assert response =~ "Sign in with GitHub"
  end
end
