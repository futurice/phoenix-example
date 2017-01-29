defmodule Blog.PostControllerTest do
  use Blog.ConnCase

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
  test "lists all the user's posts on index", %{conn: conn, user: user} do
    user_post = insert_post(user, title: "User post", body: "")
    other_post = insert_post(insert_user(username: "other"),
      title: "Other post", body: "")

    conn = get conn, post_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing posts/
    assert String.contains?(conn.resp_body, user_post.title)
    refute String.contains?(conn.resp_body, other_post.title)
  end
end
