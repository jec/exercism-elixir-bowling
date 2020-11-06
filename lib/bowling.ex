defmodule Bowling do
  @moduledoc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """

  @spec start() :: Frame.t()
  def start do
    Frame.create()
  end

  @doc """
    Records the number of pins knocked down on a single roll. Returns `any`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """

  @spec roll(Frame.t(), non_neg_integer) :: Frame.t() | Frame.error()
  def roll(frame, pin_count) do
    Frame.roll(frame, pin_count)
  end

  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful message.
  """

  @spec score(Frame.t()) :: non_neg_integer | Frame.error()
  def score(frame) do
    Frame.score(frame)
  end
end
