defmodule CowsAtRest.Utils do
  @moduledoc false

  defmodule Answer do
    @moduledoc false
    @type t :: %__MODULE__{bulls: integer, cows: integer}

    defstruct bulls: 0, cows: 0
  end

  @spec permutations([integer()], integer()) :: [[integer()]]
  def permutations(_, 0), do: [[]]

  def permutations(list, rank),
    do: for(e <- list, rest <- permutations(list -- [e], rank - 1), do: [e | rest])

  @spec cows_and_bulls_permutations() :: list(list(integer()))
  def cows_and_bulls_permutations,
    do: Enum.to_list(0..9) |> permutations(4) |> Enum.reject(&(hd(&1) == 0))

  @spec answer(list(), list()) :: Answer.t()
  def answer(inquiry, number) do
    bulls = Enum.zip_reduce(number, inquiry, 0, &if(&1 == &2, do: &3 + 1, else: &3))

    %Answer{
      bulls: bulls,
      cows: length(number) - length(inquiry -- number) - bulls
    }
  end
end
