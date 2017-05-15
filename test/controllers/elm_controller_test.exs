defmodule Tracker2x2.ElmControllerTest do
  use Tracker2x2.ConnCase

  test "it redirects if the user is not signed in", %{conn: conn} do
    conn = get conn, "/elm"
    response = html_response(conn, 302)
    assert conn.halted
    assert get_flash(conn, :error) == "Please login to continue"
  end
end
