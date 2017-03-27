defmodule Blog.UserView do
  use Blog.Web, :view
  alias Blog.User

  def render("user.json", %{user: user}) do
    %{id: user.id, username: user.username}
  end
end
