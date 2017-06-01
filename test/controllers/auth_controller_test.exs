defmodule Tracker2x2.AuthControllerTest do
  use Tracker2x2.ConnCase, async: true
  import Plug.Test
  alias Tracker2x2.AuthController

  test "#destroy", %{conn: conn} do
    conn =
      conn
      |> init_test_session(oauth_email: "test", access_token: "foo", some_other_info: "bar")
      |> AuthController.destroy(%{})
    assert get_session(conn, :current_user) == nil
    assert get_session(conn, :access_token) == nil
    assert get_session(conn, :some_other_info) == "bar"
  end

  test "#callback" do

  end
end
