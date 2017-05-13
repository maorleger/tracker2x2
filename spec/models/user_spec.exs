defmodule Tracker2x2.UserSpec do
  use ESpec.Phoenix, model: User, async: true
  alias Tracker2x2.User

  @valid_attrs %{email: "some content", encryption_version: "some content", tracker_token: "some content"}
  @invalid_attrs %{}

  describe "validation" do
    it "checks changeset with valid attributes" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end
  end
end
