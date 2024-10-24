defmodule Receitas.Repo do
  use Ecto.Repo,
    otp_app: :receitas,
    adapter: Ecto.Adapters.Postgres
end
