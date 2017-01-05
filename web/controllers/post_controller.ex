defmodule Blog.PostController do
  use Blog.Web, :controller

  alias Blog.Post

  def index(conn, _params) do
    conn
    |> assign(:posts, Repo.all(Post))
    |> render("index.html")
  end
end
