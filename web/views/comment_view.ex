defmodule Blog.CommentView do
  use Blog.Web, :view

  def render("comment.json", %{comment: comment}) do
    %{
      id: comment.id,
      body: comment.body,
      user: render_one(comment.author, Blog.UserView, "user.json")
    }
  end
end
