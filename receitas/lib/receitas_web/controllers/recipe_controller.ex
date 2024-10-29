defmodule ReceitasWeb.RecipeController do
  use ReceitasWeb, :controller

  alias Receitas.Recipes
  alias Receitas.Recipes.Recipe
  alias Receitas.{Repo, Recipes.Recipe}
  alias Receitas.Accounts.User
  import Ecto.Query, only: [from: 2]


  # def index(conn, _params) do
  #   recipes = Recipes.list_recipes()
  #   render(conn, :index, recipes: recipes)
  # end
  # def index(conn, _params) do
  #   recipes = Recipes.list_recipes() |> Enum.filter(&(!&1.is_private)) # Filtra as receitas públicas
  #   render(conn, :index, recipes: recipes)
  # end
  # def index(conn, %{"search" => search_term, "sort" => sort_order}) do
  #   recipes = Recipes.list_recipes()
  #               |> Enum.filter(&(!&1.is_private))
  #               |> Enum.filter(fn recipe -> String.contains?(recipe.title, search_term) end)


  #   render(conn, :index, recipes: recipes, search_term: search_term, sort_order: sort_order)
  # end

  def index(conn, params) do
    # Obtenha search_term e sort_order dos parâmetros, com valores padrão
    search_term = Map.get(params, "search", "")
    sort_order = Map.get(params, "sort", "asc")  # Valor padrão para sort_order

    # Filtra as receitas e aplica a ordenação
    recipes = Recipes.list_recipes()
                |> Enum.filter(&(!&1.is_private))
                |> Enum.filter(fn recipe ->
                String.contains?(String.downcase(recipe.title), String.downcase(search_term))
              end)

    # Aqui você pode aplicar a ordenação
    sorted_recipes =
      case sort_order do
        "desc" -> Enum.sort_by(recipes, & &1.inserted_at, :desc)
        _ -> Enum.sort_by(recipes, & &1.inserted_at)  # Ordenação ascendente
      end

    # Passa as variáveis para a renderização
    render(conn, :index, recipes: sorted_recipes, search_term: search_term, sort_order: sort_order)
  end

  def index(conn, _params) do
    recipes = Recipes.list_recipes()
              |> Enum.filter(&(!&1.is_private)) # Filtra as receitas públicas

    render(conn, :index, recipes: recipes)
  end

  def new(conn, _params) do
    changeset = Recipes.change_recipe(%Recipe{})
    render(conn, :new, changeset: changeset)
  end

  # def create(conn, %{"recipe" => recipe_params}) do
  #   case Recipes.create_recipe(recipe_params) do
  #     {:ok, recipe} ->
  #       conn
  #       |> put_flash(:info, "Recipe created successfully.")
  #       |> redirect(to: ~p"/recipes/#{recipe}")

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       render(conn, :new, changeset: changeset)
  #   end
  # end
  def create(conn, %{"recipe" => recipe_params}) do
    user = conn.assigns[:current_user] # Obtém o usuário atual

    # Adiciona o user_id ao mapa de parâmetros da receita
    recipe_params = Map.put(recipe_params, "user_id", user.id)

    case Recipes.create_recipe(recipe_params) do
      {:ok, recipe} ->
        conn
        |> put_flash(:info, "Recipe created successfully.")
        |> redirect(to: ~p"/recipes/#{recipe}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    recipe = Recipes.get_recipe!(id)
    render(conn, :show, recipe: recipe)
  end

  def edit(conn, %{"id" => id}) do
    recipe = Recipes.get_recipe!(id)
    changeset = Recipes.change_recipe(recipe)
    render(conn, :edit, recipe: recipe, changeset: changeset)
  end

  def update(conn, %{"id" => id, "recipe" => recipe_params}) do
    recipe = Recipes.get_recipe!(id)

    case Recipes.update_recipe(recipe, recipe_params) do
      {:ok, recipe} ->
        conn
        |> put_flash(:info, "Recipe updated successfully.")
        |> redirect(to: ~p"/recipes/#{recipe}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, recipe: recipe, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    recipe = Recipes.get_recipe!(id)
    {:ok, _recipe} = Recipes.delete_recipe(recipe)

    conn
    |> put_flash(:info, "Recipe deleted successfully.")
    |> redirect(to: ~p"/recipes")
  end

  # pedidos personalizados
  # def my_recipes(conn, _params) do
  #   user = conn.assigns[:current_user] # Fetch the current user from assigns
  #   recipes = Repo.all(from r in Recipe, where: r.user_id == ^user.id)

  #   render(conn, "my_recipes.html", recipes: recipes)
  # end
  # def my_recipes(conn, _params) do
  #   # Fetch the current user from assigns
  #   case conn.assigns[:current_user] do
  #     nil ->
  #       conn
  #       |> put_flash(:error, "Please log in to view your recipes.")
  #       |> redirect(to: "/login") # Adjust the login path if necessary
  #       |> halt()

  #     user ->
  #       recipes = Repo.all(from r in Recipe, where: r.user_id == ^user.id)
  #       render(conn, "my_recipes.html", recipes: recipes)
  #   end
  # end

  # def my_recipes(conn, _params) do
  #   user = conn.assigns[:current_user] # Pega o usuário atual da sessão

  #   # Verifica se user está presente para evitar problemas
  #   if user do
  #     recipes = Repo.all(from r in Recipe, where: r.user_id == ^user.id) # Busca receitas do usuário

  #     render(conn, "my_recipes.html", recipes: recipes)
  #   else
  #     conn
  #     |> put_flash(:error, "You need to be logged in to view your recipes.")
  #     |> redirect(to: "/users/log_in") # Redireciona para login caso não esteja autenticado
  #   end
  # end
  def my_recipes(conn, params) do
    user = conn.assigns[:current_user] # Pega o usuário atual da sessão

    # Obtenha search_term e sort_order dos parâmetros, com valores padrão
    search_term = Map.get(params, "search", "")
    sort_order = Map.get(params, "sort", "asc")

    # Define a consulta inicial com base na presença do usuário
    recipes_query =
      if user do
        # Quando o usuário está logado, busca receitas do usuário
        from r in Recipe,
          where: r.user_id == ^user.id,
          preload: [:user] # Pré-carrega a associação `user`
      end

    # Filtra receitas com o termo de busca, se presente
    recipes_query =
      if search_term != "" do
        from r in recipes_query,
        where: ilike(r.title, ^"%#{String.downcase(search_term)}%")
      else
        recipes_query
      end

    # Ordena as receitas com base no parâmetro de ordenação
    recipes_query =
      case sort_order do
        "desc" -> from r in recipes_query, order_by: [desc: r.inserted_at]
        _ -> from r in recipes_query, order_by: [asc: r.inserted_at]
      end

    # Executa a consulta
    recipes = Repo.all(recipes_query)

    # Renderiza a página my_recipes com receitas filtradas e ordenadas
    render(conn, "my_recipes.html", recipes: recipes, search_term: search_term, sort_order: sort_order)
  end
end
