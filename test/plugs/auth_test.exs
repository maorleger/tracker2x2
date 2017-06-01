defmodule Tracker2x2.AuthTest do
  use Tracker2x2.ConnCase

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Tracker2x2.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists" do

  end

end
