defmodule Blog.PostChannel do
  use Blog.Web, :channel
  alias Blog.CommentView

  def join("posts:" <> post_id, _params, socket) do
    post_id = String.to_integer(post_id)
    post = Repo.get!(Blog.Post, post_id)

    comments = Repo.all(
      from a in assoc(post, :comments),
        order_by: [asc: a.inserted_at],
        limit: 200,
        preload: [:author]
    )
    resp = %{comments: Phoenix.View.render_many(comments, CommentView, "comment.json")}
    {:ok, resp, assign(socket, :post_id, post_id)}
  end

  def handle_in(event, params, socket) do
    user = Repo.get(Blog.User, socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  def handle_in("new_comment", params, user, socket) do
    changeset =
      user
      |> build_assoc(:comments, post_id: socket.assigns.post_id)
      |> Blog.Comment.changeset(params)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast! socket, "new_comment", %{
          id: comment.id,
          user: Blog.UserView.render("user.json", %{user: user}),
          body: comment.body,
        }
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end
