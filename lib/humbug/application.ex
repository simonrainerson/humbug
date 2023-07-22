defmodule Humbug.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HumbugWeb.Telemetry,
      # Start the Ecto repository
      Humbug.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Humbug.PubSub},
      # Start Finch
      {Finch, name: Humbug.Finch},
      # Start the Endpoint (http/https)
      HumbugWeb.Endpoint
      # Start a worker by calling: Humbug.Worker.start_link(arg)
      # {Humbug.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Humbug.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HumbugWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
