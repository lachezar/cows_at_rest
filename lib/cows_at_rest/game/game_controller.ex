defmodule CowsAtRest.Game.GameController do
  @moduledoc false
  use Agent

  defmodule State do
    @moduledoc false
    @type t :: %__MODULE__{actor_at_turn_to_ask: atom(), log: [{atom(), [integer()], Answer.t()}]}

    defstruct actor_at_turn_to_ask: :player, log: []
  end

  @spec start_link(atom()) :: {:error, any()} | {:ok, pid()}
  def start_link(actor_at_turn_to_ask) do
    Agent.start_link(fn -> %State{actor_at_turn_to_ask: actor_at_turn_to_ask, log: []} end,
      name: __MODULE__
    )
  end

  @spec current_turn_to_ask() :: atom()
  def current_turn_to_ask(),
    do: Agent.get(__MODULE__, fn %State{actor_at_turn_to_ask: actor} -> actor end)

  @spec change_turn_to_ask({atom(), [integer()], Answer.t()}) :: :ok
  def change_turn_to_ask(latest_inquiry),
    do:
      Agent.update(__MODULE__, fn %State{actor_at_turn_to_ask: actor, log: log} ->
        case actor do
          :player -> %State{actor_at_turn_to_ask: :computer, log: [latest_inquiry | log]}
          :computer -> %State{actor_at_turn_to_ask: :player, log: [latest_inquiry | log]}
        end
      end)
end
