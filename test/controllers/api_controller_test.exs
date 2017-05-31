defmodule Tracker2x2.ApiControllerTest do
  use Tracker2x2.ConnCase, async: true
  import Plug.Test

  test "works", %{conn: conn} do
    user = Tracker2x2.Repo.get_by(Tracker2x2.User, email: "has_token@example.com")
    token = Phoenix.Token.sign(Tracker2x2.Endpoint, "user", user.id)
    conn = 
      conn
      |> get("/api", %{"user_id" => user.id, "token" => token})
    response = json_response(conn, 200)
    assert response =~ "Success"
  end

  test "without a valid authorization token it does something..." do
    # TODO: implement
  end

  test "when an invalid user id is passed in does something..." do
    # TODO: implement
  end
end
