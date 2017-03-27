defmodule Blog.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :author_id, references(:users, on_delete: :nothing)
    end
    create index(:posts, [:author_id])
  end
end
