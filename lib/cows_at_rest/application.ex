defmodule CowsAtRest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  @spec start(any(), any()) :: {:error, any()} | {:ok, pid()}
  def start(_type, _args) do
    children = [
      {CowsAtRest.Game.Supervisor, []},
      {Plug.Cowboy, scheme: :http, plug: CowsAtRest.Router, options: [port: 8080]}
      # Starts a worker by calling: CowsAtRest.Worker.start_link(arg)
      # {CowsAtRest.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CowsAtRest.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
