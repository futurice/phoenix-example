defmodule Blog.ReadController do
  use Blog.Web, :controller
  alias Blog.Post

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    render conn, "show.html", post: post
  end
end
