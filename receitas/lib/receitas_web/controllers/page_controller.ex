defmodule ReceitasWeb.PageController do
  use ReceitasWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_user] do
      # Redirect to "/recipes" if the user is authenticated
      redirect(conn, to: "/recipes")
    else
      # Render the home page if the user is not authenticated
      render(conn, :home, layout: false)
    end
  end
end
