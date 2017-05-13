defmodule Tracker2x2.ElmControllerSpec do
  import Plug.Test
  use ESpec.Phoenix, controller: ElmController
  alias Tracker2x2.ElmController
  before do
    conn = 
      build_conn()
    {:ok, %{conn: conn}}
  end

  let :conn, do: shared[:conn]

  describe "#authenticate" do
    describe "when the user is not logged in" do
      it "halts the connection" do
        conn = 
          conn()
          |> assign(:current_user, nil)
          |> init_test_session(oauth_email: nil)
          |> fetch_flash
          |> ElmController.authenticate({})
        expect(conn.halted).to eq(true)
        expect(get_flash(conn, :error)).to eq("Please login to continue")
        expect(redirected_to(conn)).to eq(page_path(conn, :index))
      end
    end
  end
end
