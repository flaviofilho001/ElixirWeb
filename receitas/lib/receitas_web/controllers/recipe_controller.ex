defmodule ReceitasWeb.RecipeController do
  use ReceitasWeb, :controller

  alias Receitas.Recipes
  alias Receitas.Recipes.Recipe
  alias Receitas.{Repo, Recipes.Recipe}
  alias Receitas.Accounts.User
  import Ecto.Query, only: [from: 2]

  def index(conn, params) do
    user = conn.assigns[:current_user] # Pega o usuário atual da sessão

    # Pega search_term e sort_order dos parâmetros, com valores padrão
    search_term = Map.get(params, "search", "")
    sort_order = Map.get(params, "sort", "asc")

    # Query para pegar só as receitas do usuário
    recipes_query =
        from r in Recipe,
          where: r.user_id == ^user.id

    # Filtra receitas com o termo de busca se houver
    recipes_query =
      if search_term != "" do
        from r in recipes_query,
        where: ilike(r.title, ^"%#{String.downcase(search_term)}%")
      else
        recipes_query
      end

    # Ordena as receitas com base no parâmetro de ordenação (mais antigo ou mais recente)
    recipes_query =
      case sort_order do
        "desc" -> from r in recipes_query, order_by: [desc: r.inserted_at]
        _ -> from r in recipes_query, order_by: [asc: r.inserted_at]
      end

    recipes = Recipes.list_recipes(recipes_query)

    # Renderiza a página my_recipes com receitas filtradas e ordenadas
    render(conn, "my_recipes.html", recipes: recipes, search_term: search_term, sort_order: sort_order)
  end

  def new(conn, _params) do
    changeset = Recipes.change_recipe(%Recipe{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"recipe" => recipe_params}) do
    user = conn.assigns[:current_user] # Obtém o usuário atual

    # Adiciona o user_id ao mapa de parâmetros da receita
    recipe_params = Map.put(recipe_params, "user_id", user.id)

    case Recipes.create_recipe(recipe_params) do
      {:ok, recipe} ->
        conn
        |> put_flash(:info, "Receita criada com sucesso.")
        |> redirect(to: ~p"/my-recipes/#{recipe}")

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
        |> put_flash(:info, "Receita atualizada com sucesso.")
        |> redirect(to: ~p"/my-recipes/#{recipe}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, recipe: recipe, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    recipe = Recipes.get_recipe!(id)
    {:ok, _recipe} = Recipes.delete_recipe(recipe)

    conn
    |> put_flash(:info, "Receita deletada com sucesso.")
    |> redirect(to: ~p"/my-recipes")
  end


  # Pedidos especificos

  def public_recipes(conn, params) do
    #Pega search_term e sort_order dos parâmetros, com valores padrão
    search_term = Map.get(params, "search", "")
    sort_order = Map.get(params, "sort", "asc")  # Valor padrão para sort_order

    # Filtra as receitas e aplica a ordenação
    recipes = Recipes.list_recipes()
                |> Enum.filter(&(!&1.is_private)) # remove os que são privados da brincadeira
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

  def show_public_recipe(conn, %{"id" => id}) do
    recipe = Recipes.get_recipe!(id) |> Repo.preload(:user)  # Preload para garantir que a associação user está carregada

    if recipe.is_private do
      conn
      |> put_flash(:error, "Essa receita é privada.")
      |> redirect(to: "/recipes")
    else
      render(conn, "show_public.html", recipe: recipe)
    end
  end
end
