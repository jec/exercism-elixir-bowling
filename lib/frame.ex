defmodule Frame do
  @moduledoc """
    Provides a simplified interface to RegularFrame and TenthFrame
  """

  @type t :: RegularFrame.t() | TenthFrame.t()

  @spec create(t()) :: t()
  def create(last_frame \\ nil)
  def create(nil) do
    %RegularFrame{state: :pending, data: %{number: 1, previous: nil, rolls: []}}
  end
  def create(previous = %RegularFrame{data: %{number: 9}}) do
    %TenthFrame{state: :pending, data: %{number: 10, previous: previous, rolls: []}}
  end
  def create(previous = %RegularFrame{data: %{number: frame_num}}) do
    %RegularFrame{state: :pending, data: %{number: frame_num + 1, previous: previous, rolls: []}}
  end

  @spec roll(t(), non_neg_integer) :: t()
  def roll(frame = %RegularFrame{}, pin_count) do
    result = RegularFrame.roll(frame, pin_count)
    IO.puts("roll(#{inspect frame}, #{pin_count}) returns: #{inspect result}")
    result
  end
  def roll(frame = %TenthFrame{}, pin_count) do
    result = TenthFrame.roll(frame, pin_count)
    IO.puts("roll(#{inspect frame}, #{pin_count}) returns: #{inspect result}")
    result
  end

  @spec score(t()) :: non_neg_integer
  def score(frame = %RegularFrame{}) do
    RegularFrame.score(frame)
  end
  def score(frame = %TenthFrame{}) do
    TenthFrame.score(frame)
  end
end
