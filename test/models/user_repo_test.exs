defmodule Tracker2x2.UserRepoTest do
  use Tracker2x2.ModelCase
  alias Tracker2x2.User
  alias Tracker2x2.Repo

  @valid_attrs %{email: "maor.leger@example.com", tracker_token: "some token", encryption_version: "some version"}

  def changeset(email, tracker_token \\ nil) do
    attrs = 
      Map.put(@valid_attrs, :email, email)
      |> Map.put(:tracker_token, tracker_token)
    User.changeset(%User{}, attrs)
  end

  test "errors when unique constraint fails" do
    error = {:email, {"has already been taken", []}}
    changeset("maor") |> Repo.insert!()
    assert {:error, new_changeset} = Repo.insert(changeset("maor"))
    assert new_changeset.errors == [error]
  end

  test "email is required" do
    error = {:email, {"can't be blank", [validation: :required]}}
    assert {:error, new_changeset} = Repo.insert(changeset(nil))
    assert new_changeset.errors == [error]
  end
end
