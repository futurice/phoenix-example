defmodule Blog.Post do
  use Blog.Web, :model

  @primary_key {:id, Blog.Permalink, autogenerate: true}
  schema "posts" do
    field :title, :string
    field :body, :string
    field :slug, :string
    belongs_to :author, Blog.User
    belongs_to :category, Blog.Category
    has_many :comments, Blog.Comment

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :body, :category_id])
    |> validate_required([:title, :body])
    |> slugify_title()
    |> assoc_constraint(:category)
  end

  defimpl Phoenix.Param, for: Blog.Post do
    def to_param(%{slug: slug, id: id}) do
      "#{id}-#{slug}"
    end
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end
