defmodule Blog.PostControllerTest do
  use Blog.ConnCase

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
end
