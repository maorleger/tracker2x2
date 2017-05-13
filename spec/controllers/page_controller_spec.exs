defmodule Tracker2x2.PageControllerSpec do
  import Plug.Test
  use ESpec.Phoenix, controller: PageController

  before do
    conn = 
      build_conn()
    {:ok, %{conn: conn}}
  end

  let :conn, do: shared[:conn]

  describe "when a user is not logged in" do
    it "displays oauth login buttons" do
      response = get(conn(), :index)
      expect(response.resp_body).to have("Sign in with Google")
      expect(response.resp_body).to have("Sign in with GitHub")
    end
  end

  describe "when a user is logged in" do
    it "displays a logout button" do
      response = 
        conn()
        |> init_test_session(current_user: "test")
        |> get(:index)
      expect(response.resp_body).to have("Sign out")
    end
  end
end
