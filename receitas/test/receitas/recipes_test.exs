defmodule Receitas.RecipesTest do
  use Receitas.DataCase

  alias Receitas.Recipes

  describe "recipes" do
    alias Receitas.Recipes.Recipe

    import Receitas.RecipesFixtures

    @invalid_attrs %{description: nil, title: nil, image: nil, introduction: nil, ingredients: nil, image_description: nil, is_private: nil}

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Recipes.list_recipes() == [recipe]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Recipes.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe" do
      valid_attrs = %{description: "some description", title: "some title", image: "some image", introduction: "some introduction", ingredients: "some ingredients", image_description: "some image_description", is_private: true}

      assert {:ok, %Recipe{} = recipe} = Recipes.create_recipe(valid_attrs)
      assert recipe.description == "some description"
      assert recipe.title == "some title"
      assert recipe.image == "some image"
      assert recipe.introduction == "some introduction"
      assert recipe.ingredients == "some ingredients"
      assert recipe.image_description == "some image_description"
      assert recipe.is_private == true
    end

    test "create_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recipes.create_recipe(@invalid_attrs)
    end

    test "update_recipe/2 with valid data updates the recipe" do
      recipe = recipe_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", image: "some updated image", introduction: "some updated introduction", ingredients: "some updated ingredients", image_description: "some updated image_description", is_private: false}

      assert {:ok, %Recipe{} = recipe} = Recipes.update_recipe(recipe, update_attrs)
      assert recipe.description == "some updated description"
      assert recipe.title == "some updated title"
      assert recipe.image == "some updated image"
      assert recipe.introduction == "some updated introduction"
      assert recipe.ingredients == "some updated ingredients"
      assert recipe.image_description == "some updated image_description"
      assert recipe.is_private == false
    end

    test "update_recipe/2 with invalid data returns error changeset" do
      recipe = recipe_fixture()
      assert {:error, %Ecto.Changeset{}} = Recipes.update_recipe(recipe, @invalid_attrs)
      assert recipe == Recipes.get_recipe!(recipe.id)
    end

    test "delete_recipe/1 deletes the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{}} = Recipes.delete_recipe(recipe)
      assert_raise Ecto.NoResultsError, fn -> Recipes.get_recipe!(recipe.id) end
    end

    test "change_recipe/1 returns a recipe changeset" do
      recipe = recipe_fixture()
      assert %Ecto.Changeset{} = Recipes.change_recipe(recipe)
    end
  end
end
