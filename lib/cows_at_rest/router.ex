defmodule CowsAtRest.Router do
  @moduledoc false

  use Plug.Router

  alias CowsAtRest.Game.{GameController, ComputerResponder, ComputerInquirer}
  alias CowsAtRest.Utils.Answer

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Jason)

  plug(:dispatch)

  get "/" do
    game_state = GameController.current_turn_to_ask()
    json_response(conn, game_state)
  end

  post "/player/ask" do
    with %GameController.State{actor_at_turn_to_ask: :player} <-
           GameController.current_turn_to_ask(),
         {:required_input, %{"number" => number}} <- {:required_input, conn.body_params},
         {:valid_input, true} <-
           {:valid_input, is_integer(number) && number > 999 && number < 10000},
         digits <- Integer.digits(number),
         {:non_repeating_digits, true} <- {:non_repeating_digits, Enum.uniq(digits) == digits} do
      answer = GenServer.call(ComputerResponder, player_asks: digits)
      GameController.change_turn_to_ask(digits, answer)
      json_response(conn, answer)
    else
      %GameController.State{actor_at_turn_to_ask: :computer} ->
        json_error_response(conn, "It is computer's turn to ask")

      {:required_input, _} ->
        json_error_response(conn, "The input must contain a \"number\" field")

      {:valid_input, false} ->
        json_error_response(conn, "The input must be an integer with 4 digits")

      {:non_repeating_digits, false} ->
        json_error_response(conn, "The number must have non-repeating digits")
    end
  end

  get "/computer/ask" do
    %GameController.State{actor_at_turn_to_ask: actor} = GameController.current_turn_to_ask()

    case actor do
      :player ->
        json_error_response(conn, "It is player's turn")

      :computer ->
        inquiry = GenServer.call(ComputerInquirer, :computer_asks) |> Integer.undigits()

        json_response(conn, %{inquiry: inquiry})
    end
  end

  post "/player/answer" do
    with %GameController.State{actor_at_turn_to_ask: :computer} <-
           GameController.current_turn_to_ask(),
         {:required_input, %{"bulls" => bulls, "cows" => cows}} <-
           {:required_input, conn.body_params},
         {:valid_input, true} <-
           {:valid_input,
            is_integer(bulls) && bulls >= 0 && bulls <= 4 && is_integer(cows) && cows >= 0 &&
              cows <= 4 &&
              cows + bulls <= 4} do
      answer = %Answer{bulls: bulls, cows: cows}
      inquiry = GenServer.call(ComputerInquirer, :computer_asks)
      {:ok, result} = GenServer.call(ComputerInquirer, player_answers: answer)
      GameController.change_turn_to_ask(inquiry, answer)
      json_response(conn, %{result: result})
    else
      %GameController.State{actor_at_turn_to_ask: :player} ->
        json_error_response(conn, "It is player's turn to ask")

      {:required_input, _} ->
        json_error_response(conn, "The input must contain \"bulls\" and \"cows\" fields")

      {:valid_input, false} ->
        json_error_response(
          conn,
          "The cows and bulls must be integer between 0 and 4 and their sum must not exceed 4"
        )
    end
  end

  match _ do
    json_error_response(conn, "Not found", 404)
  end

  defp json_error_response(conn, message, status_code \\ 400),
    do: json_response(conn, %{message: message}, status_code)

  defp json_response(conn, object, status_code \\ 200) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, object |> Jason.encode!())
  end
end
