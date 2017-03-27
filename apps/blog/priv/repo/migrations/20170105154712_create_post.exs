defmodule Blog.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string, null: false
      add :body, :text, null: false

      timestamps()
    end

  end
end
