defmodule RegularFrame do
  @moduledoc """
    Scores a frame of a bowling game that is not the tenth frame

    States:
    * pending -- a brand new frame with no rolls
    * open -- a frame with one roll that wasn't a strike
    * strike -- a frame with one roll that was a strike
    * spare -- a frame with two rolls that was a spare
    * closed -- a completed frame with two rolls that wasn't a spare
  """

  @type t :: %RegularFrame{state: state(), data: %{number: pos_integer, rolls: rolls(), previous: t() | nil}}

  @type state :: :pending | :open | :strike | :spare | :closed

  @type rolls :: {} | {non_neg_integer} | {non_neg_integer, non_neg_integer}

  defstruct [:data, state: :pending]

  use Fsmx.Struct, transitions: %{
    pending: [:open, :strike],
    open: [:spare, :closed]
  }

  @spec roll(t(), non_neg_integer) :: Frame.t() | Frame.error()
  def roll(%RegularFrame{state: :pending}, pin_count) when pin_count > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(%RegularFrame{state: :open, data: %{rolls: {x}}}, pin_count) when pin_count > 10 - x do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(frame = %RegularFrame{data: data}, pin_count) do
    next_frame(%{frame | data: %{data | rolls: Tuple.append(data.rolls, pin_count)}})
  end

  def score(frame = %RegularFrame{data: %{previous: last_frame}}, next_two_rolls \\ []) do
    if last_frame == nil do
      points(frame, next_two_rolls)
    else
      points(frame, next_two_rolls) + score(last_frame, two_rolls(frame, next_two_rolls))
    end
  end

  # pending -> strike; advances to a new frame
  defp next_frame(frame = %RegularFrame{state: :pending, data: %{rolls: {10}}}) do
    {:ok, new_frame} = Fsmx.transition(frame, :strike)
    Frame.create(new_frame)
  end

  # pending -> open; returns current frame
  defp next_frame(frame = %RegularFrame{state: :pending}) do
    {:ok, new_frame} = Fsmx.transition(frame, :open)
    new_frame
  end

  # open -> spare; advances to a new frame
  defp next_frame(frame = %RegularFrame{state: :open, data: %{rolls: {x, y}}}) when x + y == 10 do
    {:ok, new_frame} = Fsmx.transition(frame, :spare)
    Frame.create(new_frame)
  end

  # open -> closed; advances to a new frame
  defp next_frame(frame = %RegularFrame{state: :open}) do
    {:ok, new_frame} = Fsmx.transition(frame, :closed)
    Frame.create(new_frame)
  end

  defp points(%RegularFrame{state: :strike}, next_two_rolls) do
    10 + Enum.sum(next_two_rolls)
  end
  defp points(%RegularFrame{state: :spare, data: %{rolls: {x, y}}}, [head | _]) do
    x + y + head
  end
  defp points(%RegularFrame{state: :closed, data: %{rolls: {x, y}}}, _) do
    x + y
  end

  # Returns two rolls from the frame and, if necessary, from the next frame
  defp two_rolls(%RegularFrame{state: :strike}, [head | _]) do
    [10, head]
  end
  defp two_rolls(%RegularFrame{state: :spare, data: %{rolls: {x, y}}}, _) do
    [x, y]
  end
  defp two_rolls(%RegularFrame{state: :closed, data: %{rolls: {x, y}}}, _) do
    [x, y]
  end
end

defimpl Inspect, for: RegularFrame do
  import Inspect.Algebra

  def inspect(%RegularFrame{state: state, data: data}, opts) do
    concat(["#RegularFrame<n=", to_doc(data.number, opts), " ", to_doc(state, opts), " ", to_doc(data.rolls, opts), ">"])
  end
end
