defmodule Tracker2x2.UserTest do
  use Tracker2x2.ModelCase

  alias Tracker2x2.User

  @valid_attrs %{email: "some content", encryption_version: "some content", tracker_token: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
