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

  @type t :: %TenthFrame{state: state(), data: %{number: 10, rolls: [pos_integer], previous: t()}}

  @type state :: :pending | :roll_two | :roll_two_with_strike | :roll_three | :roll_three_with_bonus | :closed

  use Fsmx.Struct, transitions: %{
    pending: [:roll_two, :roll_two_with_strike],
    roll_two: [:roll_three_with_bonus, :closed],
    roll_two_with_strike: [:roll_three_with_bonus, :roll_three],
    roll_three: [:closed],
    roll_three_with_bonus: [:closed]
  }

  def roll(frame = %TenthFrame{data: data}, pin_count) do
    next_frame(%{frame | data: %{data | rolls: [pin_count | data.rolls]}})
  end

  def score(frame = %TenthFrame{data: %{rolls: rolls, previous: previous_frame}}) do
    Enum.sum(rolls) + RegularFrame.score(previous_frame, Enum.slice(rolls, 0..1))
  end

  # next_frame/1 determines the state transitions and whether the game advances
  # to a new frame.

  # pending -> roll_two_with_strike
  defp next_frame(frame = %TenthFrame{state: :pending, data: %{rolls: [10]}}) do
    {:ok, new_frame} = Fsmx.transition(frame, :roll_two_with_strike)
    new_frame
  end

  # pending -> roll_two
  defp next_frame(frame = %TenthFrame{state: :pending}) do
    {:ok, new_frame} = Fsmx.transition(frame, :roll_two)
    new_frame
  end

  # roll_two -> roll_three_with_bonus
  defp next_frame(frame = %TenthFrame{state: :roll_two, data: %{rolls: [x, y]}}) when x + y == 10 do
    {:ok, new_frame} = Fsmx.transition(frame, :roll_three_with_bonus)
    new_frame
  end

  # roll_two -> closed
  defp next_frame(frame = %TenthFrame{state: :roll_two}) do
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
