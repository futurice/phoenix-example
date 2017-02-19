defmodule Blog.PostChannel do
  use Blog.Web, :channel

  def join("posts:" <> post_id, _params, socket) do
    {:ok, assign(socket, :post_id, String.to_integer(post_id))}
  end
end
