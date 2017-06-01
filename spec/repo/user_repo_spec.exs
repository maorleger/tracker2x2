defmodule Tracker2x2.UserRepoSpec do
  use ESpec.Phoenix, async: true, model: User
  alias Tracker2x2.User

  @valid_attrs %{email: "A User", tracker_token: "some token", encryption_version: "some version"}

  describe "converting unique_constraint on username to error" do
    
    let :changeset do
      attrs = Map.put(@valid_attrs, :email, "maor")
      User.changeset(%User{}, attrs)
    end

    before do
      changeset()
      |> Repo.insert!()
    end

    it do: expect(Repo.insert(changeset())).to be_error_result()

    context "when name has been already taken" do
      let :new_changeset do
        {:error, changeset} = Repo.insert(changeset())
        changeset
      end

      it "has error" do
        error = {:email, {"has already been taken", []}}
        expect(new_changeset().errors).to have(error)
      end
    end
  end

  describe "required fields" do
    let :changeset do
      attrs = Map.put(@valid_attrs, :email, nil)
      User.changeset(%User{}, attrs)
    end

    it "email" do
      {:error, new_changeset} = Repo.insert(changeset())
      error = {:email, {"can't be blank", [validation: :required]}}
      expect(new_changeset.errors).to have(error)
    end
  end
end
