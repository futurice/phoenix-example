defmodule Blog.PostViewTest do
  use Blog.ConnCase, async: true
  import Phoenix.View

  test "renders index.html", %{conn: conn} do
    posts = [
      %Blog.Post{id: "1", title: "First post"},
      %Blog.Post{id: "2", title: "Second post"},
    ]
    content = render_to_string(Blog.PostView, "index.html",
      conn: conn, posts: posts)

    assert String.contains?(content, "Listing posts")
    for post <- posts do
      assert String.contains?(content, post.title)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Blog.Post.changeset(%Blog.Post{})
    categories = [{"cats", "123"}]
    content = render_to_string(Blog.PostView, "new.html",
      conn: conn, changeset: changeset, categories: categories)

    assert String.contains?(content, "New post")
  end
end
