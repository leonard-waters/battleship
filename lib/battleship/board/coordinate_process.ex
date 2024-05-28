defmodule Battleship.Board.CoordinateProcess do
  @moduledoc """
  This GenServer is used to encapsulate the state of
  a board coordinate.
  """

  use GenServer, restart: :transient

  require Logger

  alias Battleship.Board.Coordinate
  alias Battleship.Board.CoordinateRegistry, as: CoordReg

  # +------------------------------------------------------------------+
  # |               GenServer Public API Functions                     |
  # +------------------------------------------------------------------+

  @doc """
  This function is used to start the GenServer.
  """
  def start_link(%Coordinate{id: coord_id} = coordinate) do
    GenServer.start_link(__MODULE__, coordinate, name: via_tuple(coord_id))
  end

  # +------------------------------------------------------------------+
  # |                 GenServer Callback Functions                     |
  # +------------------------------------------------------------------+

  @impl true
  def init(%Coordinate{} = coordinate) do
    {:ok, coordinate}
  end

  @impl true
  def handle_call(:get_coordinate_details, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:update_coordinate_details, coordinate_details}, _from, state) do
    updated_state = Map.merge(state, coordinate_details)
    {:reply, updated_state, updated_state}
  end

  def via_tuple(coord_id) do
    {:via, Registry, {CoordReg, coord_id}}
  end
end
