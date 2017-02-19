defmodule Blog.PostChannel do
  use Blog.Web, :channel

  def join("posts:" <> post_id, _params, socket) do
    {:ok, socket}
  end

  def handle_in("new_comment", params, socket) do
    broadcast! socket, "new_comment", %{
      user: %{username: "anon"},
      body: params["body"],
    }

    {:reply, :ok, socket}
  end
end
