defmodule Receitas.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ReceitasWeb.Telemetry,
      Receitas.Repo,
      {DNSCluster, query: Application.get_env(:receitas, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Receitas.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Receitas.Finch},
      # Start a worker by calling: Receitas.Worker.start_link(arg)
      # {Receitas.Worker, arg},
      # Start to serve requests, typically the last entry
      ReceitasWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Receitas.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ReceitasWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
