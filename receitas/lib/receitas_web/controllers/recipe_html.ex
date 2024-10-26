defmodule ReceitasWeb.RecipeHTML do
  use ReceitasWeb, :html

  embed_templates "recipe_html/*"

  @doc """
  Renders a recipe form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def recipe_form(assigns)
end
