defmodule Blog.PostController do
  use Blog.Web, :controller

  alias Blog.Post

  # Add current_user as argument to all action calls
  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  def feed(conn, _params, _user) do
    posts = Repo.all(Post)
    render(conn, "feed.html", posts: posts)
  end

  def index(conn, _params, user) do
    posts = Repo.all(user_posts(user))
    render(conn, "index.html", posts: posts)
  end

  def new(conn, _params, user) do
    changeset =
      user
      |> build_assoc(:posts)
      |> Post.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"post" => post_params}, user) do
    changeset =
      user
      |> build_assoc(:posts)
      |> Post.changeset(post_params)

    case Repo.insert(changeset) do
      {:ok, _post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: post_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    post = Repo.get!(user_posts(user), id)
    render(conn, "show.html", post: post)
  end

  def edit(conn, %{"id" => id}, user) do
    post = Repo.get!(user_posts(user), id)
    changeset = Post.changeset(post)
    render(conn, "edit.html", post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}, user) do
    post = Repo.get!(user_posts(user), id)
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        render(conn, "edit.html", post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    post = Repo.get!(user_posts(user), id)
    Repo.delete!(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: post_path(conn, :index))
  end

  defp user_posts(user) do
    assoc(user, :posts)
  end
end
