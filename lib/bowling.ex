defmodule Bowling do
  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """

  defstruct [:frame]

  @spec start() :: any
  def start do
    %Bowling{frame: Frame.create()}
  end

  @doc """
    Records the number of pins knocked down on a single roll. Returns `any`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """

  @spec roll(any, integer) :: any | String.t()
  def roll(%Bowling{frame: frame}, pin_count) do
    %Bowling{frame: Frame.roll(frame, pin_count)}
  end

  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful message.
  """

  @spec score(any) :: integer | String.t()
  def score(%Bowling{frame: frame}) do
    Frame.score(frame)
  end
end
