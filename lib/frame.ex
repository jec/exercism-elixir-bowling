defmodule Frame do
  @moduledoc """
    Provides an interface to `RegularFrame` and `TenthFrame`
  """

  @type t :: RegularFrame.t() | TenthFrame.t()

  @type error :: {:error, String.t()}

  @doc """
    Creates the first `RegularFrame` to begin a game
  """

  @spec create() :: t()
  def create() do
    %RegularFrame{state: :pending, data: %{number: 1, previous: nil, rolls: {}}}
  end

  @doc """
    Creates the next frame in the game, either a `RegularFrame` or a
    `TenthFrame`, depending on the frame number of the provided frame

    The new frame receives a reference to the provided frame.
  """

  @spec create(t()) :: t()
  def create(previous = %RegularFrame{data: %{number: 9}}) do
    %TenthFrame{state: :pending, data: %{number: 10, previous: previous, rolls: {}}}
  end
  def create(previous = %RegularFrame{data: %{number: frame_num}}) do
    %RegularFrame{state: :pending, data: %{number: frame_num + 1, previous: previous, rolls: {}}}
  end

  @doc """
    Performs simple validation on `pin_count` and delegates to roll/2 in the
    appropriate module
  """

  @spec roll(t(), non_neg_integer) :: t() | error()
  def roll(_, pin_count) when pin_count < 0 do
    {:error, "Negative roll is invalid"}
  end
  def roll(frame = %RegularFrame{}, pin_count) do
    RegularFrame.roll(frame, pin_count)
  end
  def roll(frame = %TenthFrame{}, pin_count) do
    TenthFrame.roll(frame, pin_count)
  end

  @doc """
    Disallows scoring on a `RegularFrame` and delegates to TenthFrame.score/1
  """

  @spec score(t()) :: non_neg_integer | error()
  def score(%RegularFrame{}) do
    {:error, "Score cannot be taken until the end of the game"}
  end
  def score(frame = %TenthFrame{}) do
    TenthFrame.score(frame)
  end
end
