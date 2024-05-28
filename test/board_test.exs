defmodule BoardTest do
  use ExUnit.Case

  start_supervised({Battleship.Board.Coordinate, []})
  start_supervised({Battleship.Ship, []})
end
