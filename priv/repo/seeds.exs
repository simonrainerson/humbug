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
{:ok, user1} = Humbug.Users.create_user(%{name: "Chip Munk"})
{:ok, user2} = Humbug.Users.create_user(%{name: "Corey Ander"})
{:ok, user3} = Humbug.Users.create_user(%{name: "Molly Kuehl"})

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
