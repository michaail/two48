defmodule Two48.GameState do
  @moduledoc """
  Functions to manipulate gamestate
  """

  defstruct board: nil, score: 0

  @doc"""
  Creates a new empty gamestate
  """
  def new(size \\ 4) do
    %Two48.GameState{
      board: List.duplicate(nil, size) |> List.duplicate(size)  #pipe tutaj fajnie to wyszło
    }
  end

  @doc """
  Ustawia liczbę na tablicy na daną wartpość
  """
  def set(state, {row_index, column_index}, value) do
    row = state.board |> Enum.at(row_index)
                      |> List.replace_at(column_index, value)
    board = state.board |> List.replace_at(row_index, row)
    %{state | board: board}
  end

  @doc """
  Pobiera liczbę z tablicy
  """
  def get(state, {row_index, column_index}) do
    state.board
    |> Enum.at(row_index)
    |> Enum.at(column_index)
  end

  @doc """
  Sprawdza czy możliwy jest ruch liczby
  """
  def can_move?(state, direction) do
    state != move(state, direction)
  end

  @doc """
  Przesuwa liczbę w wybranym kierunku
  """
  def move(state, direction) do
    state
    |> move_transform(:before, direction)
    |> move_left
    |> move_transform(:after, direction)
  end

  @doc """
  Sprawdza czy możliwy jest jakikolwiek ruch
  """
  def game_over?(state) do
    [:left, :right, :up, :down]
    |> Enum.all?(fn direction -> !can_move?(state, direction) end)
  end

  @doc """
  Randomowe dodanie 2 lub 4 w wolne miejsce tablicy
  """
  def place_random_number(state) do
    empty_fields = state.board
    |> List.flatten
    |> Enum.with_index
    |> Enum.reject(fn {value, _index} -> value end)
    |> Enum.map(fn {_value, index} -> index end)

    num_empty_fields = length(empty_fields)
    case num_empty_fields do
      0 -> state
      _ ->
        index  = Enum.at(empty_fields, :random.uniform(num_empty_fields) - 1)
        number = if :random.uniform < 0.9, do: 2, else: 4
        size = size(state)

        set(state, {div(index, size), rem(index, size)}, number)
    end
  end

  @doc """
  Returns the size of one dimension of the board
  """
  def size(state) do
    length state.board
  end

  @doc """
  Zwraca macierz planszy
  """
  def board(state) do
    state.board
  end

  defp move_transform(state, _,       :left),  do: state
  defp move_transform(state, _,       :right), do: state |> mirror
  defp move_transform(state, :before, :up),    do: state |> rotate_left
  defp move_transform(state, :after,  :up),    do: state |> rotate_right
  defp move_transform(state, :before, :down),  do: state |> rotate_right
  defp move_transform(state, :after,  :down),  do: state |> rotate_left

  defp move_left(state) do
    {board, score} = state.board |> move_rows_left([], state.score)
    %{state | board: board, score: score}
  end

  defp mirror(state) do
    %{state | board: state.board |> Enum.map(&Enum.reverse/1)}
  end

  defp rotate_left(state), do: %{state | board: state.board |> rotate_left([])}
  defp rotate_left([[] | _tail], result), do: result
  defp rotate_left(matrix, result) do
    row    = matrix |> Enum.map(&hd/1)
    matrix = matrix |> Enum.map(&tl/1)
    rotate_left(matrix, [row | result])
  end

  defp rotate_right(state) do
    %{board: board} = rotate_left(state)
    board = board
            |> Enum.reverse
            |> Enum.map(&Enum.reverse/1)
    %{state | board: board}
  end

  defp move_rows_left([], result, score), do: { Enum.reverse(result), score }
  defp move_rows_left([head | tail], result, score) do
    {row, new_score} = move_row_left(head)
    move_rows_left(tail, [row | result], score + new_score)
  end

  defp move_row_left(row) do
    size = length(row)
    {row, score} = row
                    |> remove_nils
                    |> merge

    row = fill_nils_right(row, size - length(row))

    {row, score}
  end

  defp remove_nils(list) do
    Enum.filter(list, &(&1))
  end

  defp merge(list), do: merge(list, [], 0)
  defp merge([], result, score), do: {Enum.reverse(result), score}
  defp merge([a, a | tail], result, score) do
    merge(tail, [a * 2 | result], score + a * 2)
  end
  defp merge([a | tail], result, score) do
    merge(tail, [a | result], score)
  end

  defp fill_nils_right(list, n) do
    list ++ List.duplicate(nil, n)
  end
end

# wyświetlanie obramowań
defimpl Inspect, for: Two48.GameState do
  alias Two48.GameState

  def inspect(state, _opts) do  #patern matching
    size = state |> GameState.size
    max_digits = 5

    inspect_rows(state.board, max_digits)
    |> wrap(delimiter(size, max_digits), "Wynik : #{state.score}\r\n")
  end

  def inspect_rows(rows, max_digits) do
    rows
    |> Enum.map(&(inspect_row(&1, max_digits)))
  end

  def inspect_row(tiles, max_digits) do
    tiles
    |> Enum.map(&(inspect_tile(&1, max_digits)))
    |> wrap("|", "\r\n")
  end

  def inspect_tile(nil, max_digits) do
    pad("", max_digits)
  end
  def inspect_tile(number, max_digits) do
    number
    |> Integer.to_string
    |> pad(max_digits)
  end

  def wrap(subjects, delimiter, postfix \\ "") do
    delimiter <> Enum.join(subjects, delimiter) <> delimiter <> postfix
  end

  def pad(subject, length) do
    pad_length = length - String.length(subject)
    subject
    |> String.rjust(String.length(subject) + div(pad_length, 2) + rem(pad_length, 2))
    |> String.ljust(length)
  end

  def delimiter(size, max_digits) do
    wrap(String.duplicate("-", max_digits) |> List.duplicate(size), "|", "\r\n")
  end
end
