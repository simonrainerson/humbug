# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Humbug.Repo.insert!(%Humbug.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require Ecto.Query
user1 = Humbug.Repo.insert!(%Humbug.Users.User{name: "Chip Munk"})
user2 = Humbug.Repo.insert!(%Humbug.Users.User{name: "Corey Ander"})
user3 = Humbug.Repo.insert!(%Humbug.Users.User{name: "Molly Kuehl"})

{:ok, room1} =
  Humbug.Discussions.create_room(%{
    name: "Stuff",
    owner_id: 1
  })

{:ok, room2} =
  Humbug.Discussions.create_room(%{
    name: "Things",
    owner_id: 2
  })

{:ok, room3} =
  Humbug.Discussions.create_room(%{
    name: "Moar Things",
    owner_id: 2
  })

Humbug.Discussions.add_users_to_room(room3, [user1, user2, user3])
