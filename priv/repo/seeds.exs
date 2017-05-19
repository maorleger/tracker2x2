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

case Tracker2x2.Repo.get_by(Tracker2x2.User, email: "has_token@example.com") do
  nil -> 
    Tracker2x2.Repo.insert!(%Tracker2x2.User{email: "has_token@example.com", tracker_token: "TestToken"})
  _ -> nil
end

case Tracker2x2.Repo.get_by(Tracker2x2.User, email: "no_token@example.com") do
  nil ->
    Tracker2x2.Repo.insert!(%Tracker2x2.User{email: "no_token@example.com"})
  _ -> nil
end


