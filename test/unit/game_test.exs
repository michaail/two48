defmodule Two48.GameTest do
  use ExUnit.Case
  alias Two48.Game
  alias Two48.GameState

  def numbers(game) do
    Game.state(game)
    |> GameState.board
    |> List.flatten
    |> Enum.filter(&(&1))
  end

  test "wygenerowana tablica z 2 liczbami" do
    {:ok, game} = Game.start_link

    assert game |> numbers |> length == 2
  end

  test "dodaje numer po ruchu" do
    {:ok, game} = Game.start_link
    sum_before = game |> numbers |> Enum.reduce(&(&1 + &2))
    Game.move(game, :left)
    sum_after = game |> numbers |> Enum.reduce(&(&1 + &2))

    assert sum_after - sum_before in [2, 4]
  end

  test "blokuje niedozwolony ruch" do
    state = GameState.new
    {:ok, game} = Game.start_link(state)

    assert {:error, :illegal_move} = Game.move(game, :left)
    assert game |> numbers |> length == 0
  end
end
