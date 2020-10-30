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

  @doc """
    Validates the value of `pin_count`, appends it to the frame's rolls and
    calls next_state_and_frame/1 to return either the transitioned frame (if incomplete) or a
    new, subsequent frame
  """

  @spec roll(t(), non_neg_integer) :: Frame.t() | Frame.error()
  def roll(%RegularFrame{state: :pending}, pin_count) when pin_count > 10 do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(%RegularFrame{state: :open, data: %{rolls: {x}}}, pin_count) when pin_count > 10 - x do
    {:error, "Pin count exceeds pins on the lane"}
  end
  def roll(frame = %RegularFrame{data: data}, pin_count) do
    next_state_and_frame(%{frame | data: %{data | rolls: Tuple.append(data.rolls, pin_count)}})
  end

  @doc """
    Returns the score from this frame plus the previous frame's score

    Note that if the previous frame exists, then its score is the cumulative
    score for it plus its predecessors.

    The `next_two_rolls` argument allows the frame's subsequent frame to
    provide up to two rolls that may be counted toward this frame's total, as
    appropriate.
  """

  @spec score(t(), [non_neg_integer]) :: non_neg_integer
  def score(frame, next_two_rolls \\ [])
  def score(frame = %RegularFrame{data: %{previous: nil}}, next_two_rolls) do
    points(frame, next_two_rolls)
  end
  def score(frame = %RegularFrame{data: %{previous: last_frame}}, next_two_rolls) do
    points(frame, next_two_rolls) + score(last_frame, two_rolls(frame, next_two_rolls))
  end

  # Applies the appropriate state transition to a frame, possibly advances to a
  # new, subsequent frame and returns the resulting frame
  @spec next_state_and_frame(t()) :: Frame.t()

  # pending -> strike; advances to a new frame
  defp next_state_and_frame(frame = %RegularFrame{state: :pending, data: %{rolls: {10}}}) do
    {:ok, updated_frame} = Fsmx.transition(frame, :strike)
    Frame.create(updated_frame)
  end

  # pending -> open; returns current frame
  defp next_state_and_frame(frame = %RegularFrame{state: :pending}) do
    {:ok, updated_frame} = Fsmx.transition(frame, :open)
    updated_frame
  end

  # open -> spare; advances to a new frame
  defp next_state_and_frame(frame = %RegularFrame{state: :open, data: %{rolls: {x, y}}}) when x + y == 10 do
    {:ok, updated_frame} = Fsmx.transition(frame, :spare)
    Frame.create(updated_frame)
  end

  # open -> closed; advances to a new frame
  defp next_state_and_frame(frame = %RegularFrame{state: :open}) do
    {:ok, updated_frame} = Fsmx.transition(frame, :closed)
    Frame.create(updated_frame)
  end

  # Receives a `RegularFrame` and up to two rolls from subsequent frames and
  # calculates the score for this frame
  @spec points(t(), [non_neg_integer]) :: non_neg_integer

  # A strike scores this frame plus the next two rolls.
  defp points(%RegularFrame{state: :strike}, next_two_rolls) do
    10 + Enum.sum(next_two_rolls)
  end

  # A spare scores this frame plus the next roll.
  defp points(%RegularFrame{state: :spare, data: %{rolls: {x, y}}}, [head | _]) do
    x + y + head
  end

  # A non-strike, non-spare scores this frame only.
  defp points(%RegularFrame{state: :closed, data: %{rolls: {x, y}}}, _) do
    x + y
  end

  # Returns two rolls from the frame and, if necessary, from the next frame(s)
  #
  # These are not used to score the current frame but are used for calculating
  # the points on the previous frame, if any.
  @spec two_rolls(t(), [non_neg_integer]) :: [non_neg_integer]

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
