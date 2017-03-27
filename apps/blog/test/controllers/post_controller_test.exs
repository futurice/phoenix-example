defmodule Blog.PostControllerTest do
  use Blog.ConnCase
  alias Blog.Post

  @valid_attrs %{title: "Post Title", body: "Post body"}
  @invalid_attrs %{title: "invalid"}

  defp post_count(query), do: Repo.one(from p in query, select: count(p.id))

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, post_path(conn, :new)),
      get(conn, post_path(conn, :index)),
      get(conn, post_path(conn, :show, "123")),
      get(conn, post_path(conn, :edit, "123")),
      get(conn, post_path(conn, :update, "123", %{})),
      get(conn, post_path(conn, :create, %{})),
      get(conn, post_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "max"
  test "authorizes actions against foreign access", %{user: owner, conn: conn} do
    post = insert_post(owner, @valid_attrs)
    non_owner = insert_user(username: "sneaky")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn ->
      get(conn, post_path(conn, :show, post))
    end
    assert_error_sent :not_found, fn ->
      get(conn, post_path(conn, :edit, post))
    end
    assert_error_sent :not_found, fn ->
      get(conn, post_path(conn, :update, post, post: @valid_attrs))
    end
    assert_error_sent :not_found, fn ->
      get(conn, post_path(conn, :delete, post))
    end
  end

  @tag login_as: "max"
  test "lists all the user's posts on index", %{conn: conn, user: user} do
    user_post = insert_post(user, title: "User post", body: "")
    other_post = insert_post(insert_user(username: "other"),
      title: "Other post", body: "")

    conn = get conn, post_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing posts/
    assert String.contains?(conn.resp_body, user_post.title)
    refute String.contains?(conn.resp_body, other_post.title)
  end

  @tag login_as: "max"
  test "creates a post with the correct author and redirects", %{conn: conn, user: user} do
    conn = post conn, post_path(conn, :create), post: @valid_attrs
    assert redirected_to(conn) == post_path(conn, :index)
    assert Repo.get_by!(Post, @valid_attrs).author_id == user.id
  end

  @tag login_as: "max"
  test "does not create the post and renders errors when invalid", %{conn: conn} do
    count_before = post_count(Post)
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert post_count(Post) == count_before
  end
end
