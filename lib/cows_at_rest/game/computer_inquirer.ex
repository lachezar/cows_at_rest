defmodule CowsAtRest.Game.ComputerInquirer do
  @moduledoc false
  use GenServer

  alias CowsAtRest.Utils
  alias CowsAtRest.Utils.Answer

  defmodule State do
    @moduledoc false
    @type t :: %__MODULE__{inquiry: [integer()], candidates: [[integer()]]}

    defstruct inquiry: nil, candidates: []
  end

  @spec start_link([[integer()]]) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(candidates) when is_list(candidates) do
    GenServer.start_link(__MODULE__, candidates, name: __MODULE__)
  end

  # Callbacks

  @impl true
  @spec init([[integer()]]) :: {:ok, State.t()}
  def init(candidates) when is_list(candidates) do
    {:ok, %State{inquiry: Enum.random(candidates), candidates: candidates}}
  end

  @impl true
  def handle_call(:computer_asks, _from, state = %State{inquiry: inquiry, candidates: _}) do
    {:reply, inquiry, state}
  end

  @impl true
  def handle_call([player_answers: %Answer{bulls: 4}], _from, state) do
    GenServer.cast(self(), :game_over)
    {:reply, {:ok, :computer_won}, state}
  end

  @impl true
  def handle_call(
        [player_answers: answer = %Answer{}],
        _from,
        %State{inquiry: inquiry, candidates: candidates}
      ) do
    new_candidates = Enum.filter(candidates, &(Utils.answer(inquiry, &1) == answer))

    {:reply, :continue, %State{inquiry: Enum.random(new_candidates), candidates: new_candidates}}
  end

  @impl true
  def handle_cast(:game_over, state) do
    {:stop, :normal, state}
  end
end
