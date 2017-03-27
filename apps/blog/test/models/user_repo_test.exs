defmodule Blog.UserRepoTest do
  use Blog.ModelCase
  alias Blog.User

  @valid_attrs %{name: "Name", username: "username"}

  test "converts unique_constraint on username to error" do
    insert_user(username: "existing")
    attrs = Map.put(@valid_attrs, :username, "existing")
    changeset = User.changeset(%User{}, attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:username, {"has already been taken", []}} in changeset.errors
  end
end
