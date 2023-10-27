defmodule CowsAtRest.Game.Supervisor do
  @moduledoc false
  use Supervisor

  alias CowsAtRest.Game.{ComputerResponder, ComputerInquirer, TurnDecider}

  @candidates CowsAtRest.Utils.cows_and_bulls_permutations()

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  @spec init(any()) ::
          {:ok,
           {%{
              auto_shutdown: :all_significant | :any_significant | :never,
              intensity: non_neg_integer(),
              period: pos_integer(),
              strategy: :one_for_all | :one_for_one | :rest_for_one
            }, [{any(), any(), any(), any(), any(), any()} | map()]}}
  def init(_init_arg) do
    children = [
      {ComputerResponder, @candidates},
      {ComputerInquirer, @candidates},
      {TurnDecider, :player}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
