defmodule Blog.PostChannel do
  use Blog.Web, :channel
  alias Blog.CommentView

  def join("posts:" <> post_id, params, socket) do
    last_seen_id = params["last_seen_id"] || 0
    post_id = String.to_integer(post_id)
    post = Repo.get!(Blog.Post, post_id)

    comments = Repo.all(
      from c in assoc(post, :comments),
        where: c.id > ^last_seen_id,
        order_by: [asc: c.id],
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
        broadcast_comment(socket, comment)
        Task.start_link(fn -> compute_additional_info(comment, socket) end)
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp broadcast_comment(socket, comment) do
    # %{
    #   id: comment.id,
    #   user: Blog.UserView.render("user.json", %{user: user}),
    #   body: comment.body,
    # }

    comment = Repo.preload(comment, :author)
    rendered_comment = Phoenix.View.render(CommentView, "comment.json", %{
      comment: comment
    })
    broadcast! socket, "new_comment", rendered_comment
  end

  defp compute_additional_info(comment, socket) do
    for result <- Blog.InfoSys.compute(comment.body, limit: 1, timeout: 10_000) do
      attrs = %{url: result.url, body: result.text}
      info_changeset =
        Repo.get_by!(Blog.User, username: result.backend)
        |> build_assoc(:comments, post_id: comment.post_id)
        |> Blog.Comment.changeset(attrs)

      case Repo.insert(info_changeset) do
        {:ok, info_comment} -> broadcast_comment(socket, info_comment)
        {:error, _changeset} -> :ignore
      end
    end
  end
end
