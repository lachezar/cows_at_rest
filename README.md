# Cows and Bulls game in Elixir with Cowboy as REST API layer

More info about the game: https://en.wikipedia.org/wiki/Bulls_and_Cows

## Run it

```
mix deps.get
mix run --no-halt
```

## API examples

Try to guess computer's number:

```
curl -v --data '{"number": 1763}' -H "Content-type: application/json" http://localhost:8080/player/ask
{"bulls":0,"cows":2}
```

Look up computer's inquiry towards you:

```
curl http://localhost:8080/computer/ask
{"inquiry":5403}
```

Answer computer's inquiry:

```
curl --data '{"bulls": 1, "cows": 0}' -H "Content-type: application/json" http://localhost:8080/player/answer
{"result":"continue"}
```

Game's log:

```
curl  http://localhost:8080/
{"log":[{"number":[5,4,0,3],"answer":{"bulls":1,"cows":0},"actor":"computer"},{"number":[1,7,6,3],"answer":{"bulls":0,"cows":2},"actor":"player"}],"actor_at_turn_to_ask":"player"}
```

## Cheating

If you run the application in interactive mode with `iex -S run mix` then you can inspect the state of the `ComputerResponder` which holds the computer's number by doing `:sys.get_state(CowsAtRest.Game.ComputerResponder)`.