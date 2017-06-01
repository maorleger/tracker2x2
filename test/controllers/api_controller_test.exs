defmodule Tracker2x2.ApiControllerTest do
  use Tracker2x2.ConnCase, async: true

  def user_id do
    Tracker2x2.Repo.get_by(Tracker2x2.User, email: "has_token@example.com").id
  end

  test "works", %{conn: conn} do
    user_id = user_id()
    token = Phoenix.Token.sign(Tracker2x2.Endpoint, "user", user_id)
    conn = 
      conn
      |> get("/api", %{"user_id" => user_id, "token" => token})
    assert json_response(conn, 200) == "Success"
  end

  test "without a token it returns a 401", %{conn: conn} do
    conn = 
      conn
      |> get("/api", %{"user_id" => user_id()})

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
      |> get("/api", %{"user_id" => user_id(), "token" => "bad token"})

    assert response(conn, 401) == "unauthorized"
  end

  test "when unable to find the tracker token returns a 404", %{conn: conn} do
    no_token_user = Tracker2x2.Repo.get_by(Tracker2x2.User, email: "no_token@example.com")
    token = Phoenix.Token.sign(Tracker2x2.Endpoint, "user", no_token_user.id)
    conn =
      conn
      |> get("/api", %{"user_id" => no_token_user.id, "token" => token})

    assert response(conn, 404) == "not found"
  end
end
