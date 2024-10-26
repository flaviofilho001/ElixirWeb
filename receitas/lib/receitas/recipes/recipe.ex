defmodule Receitas.Recipes.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :description, :string
    field :title, :string
    field :image, :string
    field :introduction, :string
    field :ingredients, :string
    field :image_description, :string
    field :is_private, :boolean, default: false
    #field :user_id, :id

    belongs_to :user, Receitas.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:title, :introduction, :ingredients, :description, :image, :image_description, :is_private, :user_id])
    |> validate_required([:title, :introduction, :ingredients, :description, :image, :image_description, :is_private, :user_id])
  end
end
