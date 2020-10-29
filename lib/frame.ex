defmodule Frame do
  @moduledoc """
    Provides a simplified interface to RegularFrame and TenthFrame
  """

  @type t :: RegularFrame.t() | TenthFrame.t()

  @type error :: {:error, String.t()}

  @spec create(t()) :: t()
  def create(last_frame \\ nil)
  def create(nil) do
    %RegularFrame{state: :pending, data: %{number: 1, previous: nil, rolls: {}}}
  end
  def create(previous = %RegularFrame{data: %{number: 9}}) do
    %TenthFrame{state: :pending, data: %{number: 10, previous: previous, rolls: {}}}
  end
  def create(previous = %RegularFrame{data: %{number: frame_num}}) do
    %RegularFrame{state: :pending, data: %{number: frame_num + 1, previous: previous, rolls: {}}}
  end

  @spec roll(t(), non_neg_integer) :: t()
  def roll(_, pin_count) when pin_count < 0 do
    {:error, "Negative roll is invalid"}
  end
  def roll(frame = %RegularFrame{}, pin_count) do
    RegularFrame.roll(frame, pin_count)
  end
  def roll(frame = %TenthFrame{}, pin_count) do
    TenthFrame.roll(frame, pin_count)
  end

  @spec score(t()) :: non_neg_integer | error()
  def score(%RegularFrame{}) do
    {:error, "Score cannot be taken until the end of the game"}
  end
  def score(frame = %TenthFrame{}) do
    TenthFrame.score(frame)
  end
end
