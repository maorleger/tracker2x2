defmodule Tracker2x2.PageControllerTest do
  use Tracker2x2.ConnCase
  import Plug.Test

  test "When the user is not logged in displays login buttons", %{conn: conn} do
    conn = get conn, "/"
    response = html_response(conn, 200) 
    assert response =~ "Sign in with Google"
    assert response =~ "Sign in with GitHub"
  end

  test "When the user is logged in and has a token redirects to elm page", %{conn: conn} do
    conn = 
      conn
      |> init_test_session(oauth_email: "has_token@example.com")
      |> get "/"

    assert redirected_to(conn) == "/elm"
    assert conn.halted
  end

  test "when the user is logged in and has no token reidrects to token page", %{conn: conn} do
    conn =
      conn
      |> init_test_session(oauth_email: "no_token@example.com")
      |> get "/"

    assert redirected_to(conn) == "/elm/edit"
    assert conn.halted

  end
end
