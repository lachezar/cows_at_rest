defmodule CowsAtRest.Game.ComputerResponder do
  @moduledoc false
  use GenServer

  alias CowsAtRest.Utils

  @spec start_link([[integer()]]) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(candidates) when is_list(candidates) do
    GenServer.start_link(__MODULE__, candidates, name: __MODULE__)
  end

  # Callbacks

  @impl true
  @spec init([[integer()]]) :: {:ok, [integer()]}
  def init(candidates) do
    {:ok, Enum.random(candidates)}
  end

  @impl true
  def handle_call([player_asks: candidate], _from, number) do
    answer = Utils.answer(candidate, number)
    if answer.bulls == 4, do: GenServer.cast(self(), :game_over)

    {:reply, answer, number}
  end

  @impl true
  def handle_cast(:game_over, state) do
    {:stop, :normal, state}
  end
end
