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
    %GameController.State{actor_at_turn_to_ask: actor} = GameController.current_turn_to_ask()
    %{"number" => number} = conn.body_params

    if is_integer(number) && number > 999 && number < 10000 do
      digits = Integer.digits(number)

      if Enum.uniq(digits) == digits do
        case actor do
          :player ->
            answer = GenServer.call(ComputerResponder, player_asks: digits)
            GameController.change_turn_to_ask(actor, digits, answer)

            json_response(conn, answer)

          :computer ->
            json_error_response(conn, "It is computer's turn")
        end
      else
        json_error_response(conn, "The number must have non-repeating digits")
      end
    else
      json_error_response(conn, "The input must be an integer with 4 digits")
    end
  end

  get "/computer/ask" do
    %GameController.State{actor_at_turn_to_ask: actor} = GameController.current_turn_to_ask()

    case actor do
      :player ->
        json_error_response(conn, "It is player's turn")

      :computer ->
        inquiry = GenServer.call(ComputerInquirer, :computer_asks)

        json_response(conn, %{inquiry: inquiry})
    end
  end

  post "/player/answer" do
    %GameController.State{actor_at_turn_to_ask: actor} = GameController.current_turn_to_ask()
    %{"bulls" => bulls, "cows" => cows} = conn.body_params

    if is_integer(bulls) && bulls >= 0 && bulls <= 4 && is_integer(cows) && cows >= 0 && cows <= 4 &&
         cows + bulls <= 4 do
      case actor do
        :player ->
          json_error_response(conn, "It is computer's turn")

        :computer ->
          answer = %Answer{bulls: bulls, cows: cows}

          inquiry = GenServer.call(ComputerInquirer, :computer_asks)

          {:ok, result} =
            GenServer.call(ComputerInquirer, player_answers: answer)

          GameController.change_turn_to_ask(actor, inquiry, answer)
          json_response(conn, %{result: result})
      end
    else
      json_error_response(
        conn,
        "The cows and bulls must be between 0 and 4 and their sum must not exceed 4"
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
