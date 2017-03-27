defmodule Blog.Repo.Migrations.CreateComment do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :body, :text
      add :author_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end
    create index(:comments, [:author_id])
    create index(:comments, [:post_id])

  end
end
