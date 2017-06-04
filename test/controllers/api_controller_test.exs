defmodule Tracker2x2.ApiControllerTest do
  use Tracker2x2.ConnCase, async: true

  test "works", %{conn: conn} do
    user_id = token_user()
    token = gen_token(user_id)
    conn = 
      conn
      |> put_req_header("token", token)
      |> get("/api", %{"user_id" => user_id})
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
      |> put_req_header("token", "bad token")
      |> get("/api", %{"user_id" => token_user()})

    assert response(conn, 401) == "unauthorized"
  end

  test "when both the token and user_id are invalid returns a 401", %{conn: conn} do
    conn =
      conn
      |> put_req_header("token", gen_token("Maor"))
      |> get("/api", %{"user_id" => "Maor"})

      assert response(conn, 401) == "unauthorized"
  end

  test "when the user_id does not match the user_id in the token returns a 401", %{conn: conn} do
    no_token_user_id = no_token_user()
    token_user_id = token_user()

    token = gen_token(no_token_user_id)
    conn =
      conn
      |> put_req_header("token", token)
      |> get("/api", %{"user_id" => token_user_id})

    assert response(conn, 401) == "unauthorized"
  end

  test "all endpoints return a 404 when unable to find the tracker token", %{conn: conn} do
    no_token_user_id = no_token_user()
    token = gen_token(no_token_user_id)
    Enum.each(["", "/1987/epics"], fn(path) -> 
      conn =
        conn
        |> put_req_header("token", token)
        |> get("/api#{path}", %{"user_id" => no_token_user_id})

        assert response(conn, 404) == "not found"
    end)
  end

  test "getEpics endpoint works", %{conn: conn} do
    token_user_id = token_user()
    conn =
      conn
      |> put_req_header("token", gen_token(token_user_id))
      |> get("/api/1987/epics", %{"user_id" => token_user_id})

    assert json_response(conn, 200) == %{"epics" => ["Epic1", "Epic2", "Epic3"]}
  end

  def token_user do
    Tracker2x2.Repo.get_by(Tracker2x2.User, email: "has_token@example.com").id
  end

  def no_token_user do
    Tracker2x2.Repo.get_by(Tracker2x2.User, email: "no_token@example.com").id
  end

  def gen_token(user_id) do
    Phoenix.Token.sign(Tracker2x2.Endpoint, System.get_env("APP_SALT"), user_id)
  end

end
