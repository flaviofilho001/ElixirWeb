defmodule Receitas.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :title, :string
      add :introduction, :text
      add :ingredients, :text
      add :description, :text
      add :image, :string
      add :image_description, :string
      add :is_private, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:recipes, [:user_id])
  end
end
