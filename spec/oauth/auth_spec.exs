# defmodule Tracker2x2.AuthSpec do
#   import Plug.Test
#   use ESpec.Phoenix
#   alias Tracker2x2.Auth

#   before do
#     conn =
#       SHOULD BE SOMETHING WITH SESSION
#       |> init_test_session(oauth_email: nil)
#   end

#   let :conn, do: shared[:conn]

#   describe "without a signed in user" do
#     it "does not assign a user" do
#       new_conn = Auth.call(conn, {})
#       expect(new_conn.assigns.current_user).to be_nil
#     end
#   end

#   describe "with a signed in user" do
#     it "sets up an internal user record" do
#       new_conn = 
#         conn
#         |> put_session(:current_user, %{oauth_email: "maor.leger@gmail.com"})
#         |> Auth.call({})
#       expect(new_conn.assigns.current_user).not_to be_nil
#     end
#   end
# end
