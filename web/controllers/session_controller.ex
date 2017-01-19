defmodule Blog.SessionController do
  use Blog.Web, :controller

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"username" => user, "password" => pass}}) do
    case Blog.Auth.login_by_username_and_pass(conn, user, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: post_path(conn, :index))
      {:error, reason, conn} ->
        conn
        |> put_flash(:error, error_message(reason))
        |> render("new.html")
    end
  end

  defp error_message(reason) do
    case reason do
      :unauthorized ->
        "You gave an incorrect password."
      :not_found ->
        "We couldn't find a user with this username."
    end
  end
end
