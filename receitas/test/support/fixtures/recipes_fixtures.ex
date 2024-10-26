defmodule Receitas.RecipesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Receitas.Recipes` context.
  """

  @doc """
  Generate a recipe.
  """
  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{
        description: "some description",
        image: "some image",
        image_description: "some image_description",
        ingredients: "some ingredients",
        introduction: "some introduction",
        is_private: true,
        title: "some title"
      })
      |> Receitas.Recipes.create_recipe()

    recipe
  end
end
