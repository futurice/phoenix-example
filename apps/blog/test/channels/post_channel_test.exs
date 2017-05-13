defmodule Blog.Channels.PostChannelTest do
  use Blog.ChannelCase
  import Blog.TestHelpers

  setup do
    user = insert_user(name: "Rebecca")
    post = insert_post(user, title: "Testing", body: "Lorem ipsum")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(Blog.UserSocket, %{"token" => token})

    {:ok, socket: socket, user: user, post: post} # adds these to test context
  end

  test "join replies with post comments", %{socket: socket, post: post} do
    for body <- ~w(one two) do
      post
      |> build_assoc(:comments, %{body: body})
      |> Repo.insert!
    end
    {:ok, reply, socket} = subscribe_and_join(socket, "posts:#{post.id}", %{})

    assert socket.assigns.post_id == post.id
    assert %{comments: [%{body: "one"}, %{body: "two"}]} = reply
  end

  test "inserting new comments", %{socket: socket, post: post} do
    {:ok, _, socket} = subscribe_and_join(socket, "posts:#{post.id}", %{})
    ref = push socket, "new_comment", %{body: "A new body"}
    assert_reply ref, :ok, %{}
    assert_broadcast "new_comment", %{}
  end

  test "new comments trigger InfoSys", %{socket: socket, post: post} do
    insert_user(username: "wolfram")
    {:ok, _, socket} = subscribe_and_join(socket, "posts:#{post.id}", %{})
    ref = push socket, "new_comment", %{body: "1 + 1"}
    assert_reply ref, :ok, %{}
    assert_broadcast "new_comment", %{body: "1 + 1"}
    assert_broadcast "new_comment", %{body: "2"}
  end
end
