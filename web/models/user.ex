defmodule Tracker2x2.User do
  @moduledoc """
    User model, defining a user with a tracker token and email
  """
  use Tracker2x2.Web, :model

  schema "users" do
    field :email, :string
    field :tracker_token, Cloak.EncryptedBinaryField
    field :encryption_version, :binary

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :tracker_token, :encryption_version])
    |> validate_required([:email])
    |> unique_constraint(:email)
    |> put_change(:encryption_version, Cloak.version)
  end
end
