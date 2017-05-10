defmodule ElmControllerSpec do
  use ESpec.Phoenix, controller: ElmController

  let :response do
    build_conn
    |> get(:index)
  end

  describe "when the user is not logged in" do
  end
end
