defmodule PageControllerSpec do
  use ESpec.Phoenix, controller: PageController

  let :response do
    build_conn
    |> get(:index)
  end

  describe "when a user is not logged in" do
    it "displays oauth login buttons" do
      expect(response.resp_body).to have("Sign in with Google")
      expect(response.resp_body).to have("Sign in with GitHub")
    end
  end

  describe "when a user is logged in" do
    before do
      conn =
        build_conn()
        |> bypass_through(Tracker2x2.Router, :browser)
        |> get("/")
        |> put_session(:current_user, %{name: "Maor Leger", email: "maor.leger@example.com"})
        |> get("/")
      {:ok, %{conn: conn}}
    end

    it "displays a logout button" do
      expect(response.resp_body).to have("Sign out")
    end
  end
end
