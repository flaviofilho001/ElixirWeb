defmodule ReceitasWeb.PageController do
  use ReceitasWeb, :controller

  def home(conn, _params) do
    if conn.assigns[:current_user] do
      # Redireciona para "/recipes" se o usuário estiver autenticado
      redirect(conn, to: "/recipes")
    else
      # Redireciona para home se o usuário não tá autenticado
      render(conn, :home, layout: false)
    end
  end
end
