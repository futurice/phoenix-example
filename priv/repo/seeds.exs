# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Blog.Repo.insert!(%Blog.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Blog.Repo
alias Blog.User
alias Blog.Category

# Create demo user
Repo.insert!(User.registration_changeset(%User{},
  %{name: "Demo User", username: "demo", password: "secret"}))

# Create Wolfram Alpha bot
Repo.insert!(User.registration_changeset(%User{},
  %{name: "Wolfram Alpha", username: "wolfram", password: "wolfram"}))

for category <- ["Coding", "World Domination", "Testing"] do
  Repo.get_by(Category, name: category) ||
    Repo.insert!(%Category{name: category})
end
