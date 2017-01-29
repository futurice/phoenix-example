defmodule Blog.Post do
  use Blog.Web, :model

  schema "posts" do
    field :title, :string
    field :body, :string
    belongs_to :author, Blog.User
    belongs_to :category, Blog.Category

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body, :category_id])
    |> validate_required([:title, :body])
    |> assoc_constraint(:category)
  end
end
