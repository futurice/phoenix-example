defmodule Blog.TestHelpers do
  alias Blog.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "Some user",
      username: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}",
      password: "supersecret",
    }, attrs)

    %Blog.User{}
    |> Blog.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_post(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:posts, attrs)
    |> Repo.insert!()
  end
end
