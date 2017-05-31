defmodule Tracker2x2.PageControllerTest do
  use Tracker2x2.ConnCase, async: true
  import Plug.Test

  test "When the user is not logged in displays login buttons", %{conn: conn} do
    conn = get conn, "/"
    response = html_response(conn, 200) 
    assert response =~ "Sign in with Google"
    assert response =~ "Sign in with GitHub"
  end

  test "When the user is logged in and has a token redirects to app page", %{conn: conn} do
    conn = 
      conn
      |> init_test_session(oauth_email: "has_token@example.com")
      |> get("/")

    assert redirected_to(conn) == app_path(conn, :index)
    assert conn.halted
  end

  test "when the user is logged in and has no token reidrects to token edit page", %{conn: conn} do
    conn =
      conn
      |> init_test_session(oauth_email: "no_token@example.com")
      |> get("/")

    assert redirected_to(conn) == app_path(conn, :edit)
    assert conn.halted

  end
end
