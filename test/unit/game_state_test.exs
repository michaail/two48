defmodule Two48.GameStateTest do
  use ExUnit.Case
  alias Two48.GameState

  @board_1 GameState.new |> GameState.set({2, 2}, 2)
  @board_2 @board_1 |> GameState.set({2, 0}, 2)
  @board_3 @board_2 |> GameState.set({2, 1}, 2)

  # Get and set
  test "it can set and get a spcific field" do
    field = GameState.new
            |> GameState.set({0, 3}, 32)
            |> GameState.get({0, 3})
    assert field == 32
  end

  # Move
  test "it moves a number left" do
    state = @board_1 |> GameState.move(:left)
    assert state |> GameState.get({2, 0}) == 2
  end

  test "it moves a number right" do
    state = @board_1 |> GameState.move(:right)
    assert state |> GameState.get({2, 3}) == 2
  end

  test "it moves a number up" do
    state = @board_1 |> GameState.move(:up)
    assert state |> GameState.get({0, 2}) == 2
  end

  test "it moves a number down" do
    state = @board_1 |> GameState.move(:down)
    assert state |> GameState.get({3, 2}) == 2
  end

  test "it merges two numbers" do
    state = @board_2 |> GameState.move(:left)
    assert state |> GameState.get({2, 0}) == 4
  end

  test "it merges the right numbers" do
    state = @board_3 |> GameState.move(:left)
    assert state |> GameState.get({2, 0}) == 4
    assert state |> GameState.get({2, 1}) == 2
  end

  test "it adds to score when merging" do
    state = @board_2 |> GameState.move(:left)
    assert state.score == 4
  end

  # place_random_number
  test "it adds a random number" do
    state = GameState.new |> GameState.place_random_number
    [number | []] = state.board |> List.flatten |> Enum.filter(&(&1))

    assert number in [2, 4]
  end

  # Size
  test "it has variable size" do
    state = GameState.new(5)
            |> GameState.set({1, 1}, 2)
            |> GameState.set({2, 2}, 4)
            |> GameState.set({3, 3}, 8)
            |> GameState.move(:left)
            |> GameState.move(:down)
            |> GameState.move(:right)
            |> GameState.move(:up)

    assert GameState.get(state, {0, 4}) == 2
    assert GameState.get(state, {1, 4}) == 4
    assert GameState.get(state, {2, 4}) == 8
  end

  # Game over
  test "it can move left" do
    state = GameState.new |> GameState.set({1, 1}, 2)
    assert GameState.can_move?(state, :left)
  end

  test "it can not move left" do
    state = GameState.new |> GameState.set({1, 0}, 2)
    refute GameState.can_move?(state, :left)
  end

  test "it is not game over" do
    state = GameState.new |> GameState.set({1, 0}, 2)
    refute GameState.game_over?(state)
  end

  test "it is game over" do
    board = [
      [2, 4, 2, 4],
      [4, 2, 4, 2],
      [2, 4, 2, 4],
      [4, 2, 4, 2]
    ]
    state = %{GameState.new | board: board}

    assert GameState.game_over?(state)
  end

  test "it inspects nicely" do
    board = [
      [2, 4, 8, 16],
      [32, 64, 128, 256],
      [512, 1024, 2048, 4096],
      [8192, 16384, 32768, nil]
    ]
    state = %{GameState.new | board: board, score: 1234}

    expected = """
    |-----|-----|-----|-----|\r
    |  2  |  4  |  8  |  16 |\r
    |-----|-----|-----|-----|\r
    |  32 |  64 | 128 | 256 |\r
    |-----|-----|-----|-----|\r
    | 512 | 1024| 2048| 4096|\r
    |-----|-----|-----|-----|\r
    | 8192|16384|32768|     |\r
    |-----|-----|-----|-----|\r
    Wynik : 1234\r
    """

    assert state |> inspect == expected
  end
end
