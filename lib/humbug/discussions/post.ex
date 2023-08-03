defmodule Humbug.Discussions.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Humbug.Users.User
  alias Humbug.Discussions.Topic

  schema "posts" do
    field :message, :string
    belongs_to :author, User
    belongs_to :topic, Topic

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:message, :author_id, :topic_id])
    |> validate_required([:message, :author_id, :topic_id])
  end
end
