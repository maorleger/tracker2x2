defmodule Tracker2x2.PageControllerTest do
  use Tracker2x2.ConnCase
  import Plug.Test

  test "When the user is not logged in displays login buttons", %{conn: conn} do
    conn = get conn, "/"
    response = html_response(conn, 200) 
    assert response =~ "Sign in with Google"
    assert response =~ "Sign in with GitHub"
  end

  test "When the user is logged in displays logout button", %{conn: conn} do
    conn = 
      conn
      |> init_test_session(oauth_email: "maor.leger@example.com")
      |> get "/"

    response = html_response(conn, 302)
    assert conn.halted
  end
end
