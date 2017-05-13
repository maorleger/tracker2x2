defmodule Tracker2x2.AuthControllerSpec do
  import Plug.Test
  use ESpec.Phoenix, controller: AuthController
  alias Tracker2x2.AuthController

  before do
    conn =
      build_conn()
      |> init_test_session(current_user: "test", access_token: "foo", some_other_info: "bar")
    {:ok, %{conn: conn}}
  end

  let :conn, do: shared[:conn]

  describe "#destroy" do
    it "removes all user info from the session" do
      conn = AuthController.destroy(conn(), %{})
      expect(get_session(conn, :current_user)).to eq(nil)
      expect(get_session(conn, :access_token)).to eq(nil)
      expect(get_session(conn, :some_other_info)).to eq("bar")
    end
  end

  describe "#callback" do
    before do
      allow(AuthController).to accept(
        get_token!: fn(provider, code) -> "Test Token" end,
        get_user!: fn(_,_) -> %{name: "Maor", email: "maor.leger@example.com" } end
      )
    end
    it "sets the session variables" do
      # conn = AuthController.callback(conn(), %{"provider" => "test", "code" => "Test Code"})

    end
  end

end
