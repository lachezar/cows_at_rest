defmodule CowsAtRest.Game.GameController do
  @moduledoc false
  use Agent

  defmodule LogEntry do
    @moduledoc false
    @type t :: %__MODULE__{actor: atom(), number: [integer()], answer: Answer.t()}

    @derive Jason.Encoder
    defstruct actor: :player, number: [], answer: nil
  end

  defmodule State do
    @moduledoc false
    @type t :: %__MODULE__{actor_at_turn_to_ask: atom(), log: [LogEntry.t()]}

    @derive Jason.Encoder
    defstruct actor_at_turn_to_ask: :player, log: []
  end

  @spec start_link(atom()) :: {:error, any()} | {:ok, pid()}
  def start_link(actor_at_turn_to_ask) do
    Agent.start_link(fn -> %State{actor_at_turn_to_ask: actor_at_turn_to_ask, log: []} end,
      name: __MODULE__
    )
  end

  @spec current_turn_to_ask() :: State.t()
  def current_turn_to_ask(),
    do: Agent.get(__MODULE__, & &1)

  @spec change_turn_to_ask(atom(), [integer()], Answer.t()) :: :ok
  def change_turn_to_ask(actor, number, answer) do
    log_entry = %LogEntry{actor: actor, number: number, answer: answer}

    Agent.update(__MODULE__, fn %State{actor_at_turn_to_ask: actor, log: log} ->
      case actor do
        :player -> %State{actor_at_turn_to_ask: :computer, log: [log_entry | log]}
        :computer -> %State{actor_at_turn_to_ask: :player, log: [log_entry | log]}
      end
    end)
  end
end
