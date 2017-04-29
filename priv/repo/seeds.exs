# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tracker2x2.Repo.insert!(%Tracker2x2.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Tracker2x2.Repo.delete_all Tracker2x2.User

Tracker2x2.User.changeset(%Tracker2x2.User{}, %{name: "Test User", email: "testuser@example.com", password: "secret", password_confirmation: "secret"})
|> Tracker2x2.Repo.insert!
