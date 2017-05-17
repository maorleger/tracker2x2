defmodule Tracker2x2.AuthTest do
  use Tracker2x2.ConnCase
  import Plug.Test
  alias Tracker2x2.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(Tracker2x2.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists",  %{conn: conn} do

  end

end
