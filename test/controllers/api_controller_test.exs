defmodule Tracker2x2.ApiControllerTest do
  use Tracker2x2.ConnCase, async: true


  test "works", %{conn: conn} do
    user_id = token_user()
    token = Phoenix.Token.sign(Tracker2x2.Endpoint, System.get_env("APP_SALT"), user_id)
    conn = 
      conn
      |> get("/api", %{"user_id" => user_id, "token" => token})
    assert json_response(conn, 200) == "Success"
  end

  test "without a token it returns a 401", %{conn: conn} do
    conn = 
      conn
      |> get("/api", %{"user_id" => token_user()})

    assert response(conn, 401) == "unauthorized"
  end


  test "without a user_id it returns a 401", %{conn: conn} do
    conn = 
      conn
      |> get("/api", %{"token" => "Some Token"})

    assert response(conn, 401) == "unauthorized"
  end

  test "when the token is invalid returns a 401", %{conn: conn} do
    conn =
      conn
      |> get("/api", %{"user_id" => token_user(), "token" => "bad token"})

    assert response(conn, 401) == "unauthorized"
  end

  test "when the user_id does not match the user_id in the token returns a 401", %{conn: conn} do
    no_token_user_id = no_token_user()
    token_user_id = token_user()

    token = Phoenix.Token.sign(Tracker2x2.Endpoint, System.get_env("APP_SALT"), no_token_user_id)
    conn =
      conn
      |> get("/api", %{"user_id" => token_user_id, "token" => token})

    assert response(conn, 401) == "unauthorized"
  end

  test "when unable to find the tracker token returns a 404", %{conn: conn} do
    no_token_user_id = no_token_user()
    token = Phoenix.Token.sign(Tracker2x2.Endpoint, System.get_env("APP_SALT"), no_token_user_id)
    conn =
      conn
      |> get("/api", %{"user_id" => no_token_user_id, "token" => token})

    assert response(conn, 404) == "not found"
  end

  def token_user do
    Tracker2x2.Repo.get_by(Tracker2x2.User, email: "has_token@example.com").id
  end

  def no_token_user do
    Tracker2x2.Repo.get_by(Tracker2x2.User, email: "no_token@example.com").id
  end

end
