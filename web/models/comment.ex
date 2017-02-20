defmodule Blog.Comment do
  use Blog.Web, :model

  schema "comments" do
    field :body, :string
    belongs_to :author, Blog.User
    belongs_to :post, Blog.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:body])
    |> validate_required([:body])
  end
end
