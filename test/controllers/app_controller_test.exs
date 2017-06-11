defmodule Tracker2x2.AppControllerTest do
  use Tracker2x2.ConnCase, async: true
  import Plug.Test

  test "all actions are guarded against users not signed in", %{conn: conn} do
    Enum.each([:index, :edit, :update], fn(action) ->
      action_conn = 
        case action do
          :update -> 
            put(conn, app_path(conn, action), %{"user" => {}})
          _ -> 
            get(conn, app_path(conn, action))
        end

      assert action_conn.halted
      assert redirected_to(action_conn) == page_path(conn, :index)
      assert get_flash(action_conn, :error) == "Please login to continue"
    end)
  end

  test "it shows a logout button if the user is logged in", %{conn: conn} do
    conn =
      conn
      |> init_test_session(oauth_email: "has_token@example.com")
      |> get("/app")

    response = html_response(conn, 200)
    assert response =~ "Sign out"
    assert response =~ "Update your token"
  end
  
  test "it redirects without flash if the user has no token", %{conn: conn} do
    conn =
      conn
      |> init_test_session(oauth_email: "no_token@example.com")
      |> get("/app")

    assert conn.halted
    assert get_flash(conn, :error) == nil
  end

  test "update will set the tracker token", %{conn: conn} do
    conn
    |> init_test_session(oauth_email: "has_token@example.com")
    |> put("/app/update", %{"user" => %{"tracker_token" => "New Shiny Token"}})

    assert Tracker2x2.Repo.get_by(Tracker2x2.User, email: "has_token@example.com").tracker_token == "New Shiny Token"
  end

  test "it sets the session token if all is well", %{conn: conn} do
    conn = 
      conn
      |> init_test_session(oauth_email: "has_token@example.com")
      |> get("/app")

    assert conn.assigns.token
  end
end
