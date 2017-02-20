defmodule Blog.User do
  use Blog.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :posts, Blog.Post, foreign_key: :author_id
    has_many :comments, Blog.Comment, foreign_key: :author_id

    timestamps()
  end

  def changeset(struct, params \\ :empty) do
    struct
    |> cast(params, ~w(name username))
    |> validate_required([:name, :username])
    |> unique_constraint(:username)
  end

  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, ~w(password))
    |> validate_required([:password])
    |> validate_length(:password, min: 6)
    |> put_pass_hash
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
