defmodule TenthFrame do
  @moduledoc """
    Scores the final frame of a bowling game

    States:
    * pending -- a brand new frame with no rolls
    * roll_two -- a frame with one roll that wasn't a strike
    * roll_two_with_strike -- a frame with one roll that was a strike
    * roll_three -- a frame with two rolls: a strike followed by a non-strike
    * roll_three_with_bonus -- a frame with two rolls: either two strikes or a spare
    * closed -- a completed frame
  """

  defstruct [:data, state: :pending]

  @type t :: %TenthFrame{state: state(), data: %{number: 10, rolls: rolls(), previous: t()}}

  @type state :: :pending | :roll_two | :roll_two_with_strike | :roll_three | :roll_three_with_bonus | :closed

  @type rolls :: {} | {non_neg_integer} | {non_neg_integer, non_neg_integer} | {non_neg_integer, non_neg_integer, non_neg_integer}

  use Fsmx.Struct, transitions: %{
    pending: [:roll_two, :roll_two_with_strike],
    roll_two: [:roll_three_with_bonus, :closed],
    roll_two_with_strike: [:roll_three_with_bonus, :roll_three],
    roll_three: [:closed],
    roll_three_with_bonus: [:closed]
  }

  @spec roll(t(), non_neg_integer) :: t() | Frame.error()
  def roll(%TenthFrame{state: :pending}, pin_count) when pin_count > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(%TenthFrame{state: :roll_two, data: %{rolls: {x}}}, pin_count) when pin_count > 10 - x do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(%TenthFrame{state: :roll_two_with_strike}, pin_count) when pin_count > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(%TenthFrame{state: :roll_three, data: %{rolls: {_x, y}}}, pin_count) when pin_count > 10 - y do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(%TenthFrame{state: :roll_three_with_bonus}, pin_count) when pin_count > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(%TenthFrame{state: :closed}, _pin_count) do
    {:error, "Cannot roll after game is over"}
  end
  def roll(frame = %TenthFrame{data: data}, pin_count) do
    next_frame(%{frame | data: %{data | rolls: Tuple.append(data.rolls, pin_count)}})
  end

  @spec score(t()) :: non_neg_integer | Frame.error()
  def score(%TenthFrame{state: :closed, data: %{rolls: rolls, previous: previous_frame}}) do
    rolls_as_list = Tuple.to_list(rolls)
    Enum.sum(rolls_as_list) + RegularFrame.score(previous_frame, Enum.slice(rolls_as_list, 0..1))
  end
  def score(_) do
    {:error, "Score cannot be taken until the end of the game"}
  end

  # next_frame/1 determines the state transitions and whether the game advances
  # to a new frame.

  # pending -> roll_two_with_strike
  defp next_frame(frame = %TenthFrame{state: :pending, data: %{rolls: {10}}}) do
    {:ok, new_frame} = Fsmx.transition(frame, :roll_two_with_strike)
    new_frame
  end

  # pending -> roll_two
  defp next_frame(frame = %TenthFrame{state: :pending}) do
    {:ok, new_frame} = Fsmx.transition(frame, :roll_two)
    new_frame
  end

  # roll_two -> roll_three_with_bonus
  defp next_frame(frame = %TenthFrame{state: :roll_two, data: %{rolls: {x, y}}}) when x + y == 10 do
    {:ok, new_frame} = Fsmx.transition(frame, :roll_three_with_bonus)
    new_frame
  end

  # roll_two -> closed
  defp next_frame(frame = %TenthFrame{state: :roll_two}) do
    {:ok, new_frame} = Fsmx.transition(frame, :closed)
    new_frame
  end

  # roll_two_with_strike -> roll_three_with_bonus
  defp next_frame(frame = %TenthFrame{state: :roll_two_with_strike, data: %{rolls: {10, 10}}}) do
    {:ok, new_frame} = Fsmx.transition(frame, :roll_three_with_bonus)
    new_frame
  end

  # roll_two_with_strike -> roll_three
  defp next_frame(frame = %TenthFrame{state: :roll_two_with_strike}) do
    {:ok, new_frame} = Fsmx.transition(frame, :roll_three)
    new_frame
  end

  # roll_three -> closed
  defp next_frame(frame = %TenthFrame{state: :roll_three}) do
    {:ok, new_frame} = Fsmx.transition(frame, :closed)
    new_frame
  end

  # roll_three_with_bonus -> closed
  defp next_frame(frame = %TenthFrame{state: :roll_three_with_bonus}) do
    {:ok, new_frame} = Fsmx.transition(frame, :closed)
    new_frame
  end
end

defimpl Inspect, for: TenthFrame do
  import Inspect.Algebra

  def inspect(%TenthFrame{state: state, data: data}, opts) do
    concat(["#TenthFrame<n=", to_doc(data.number, opts), " ", to_doc(state, opts), " ", to_doc(data.rolls, opts), ">"])
  end
end
