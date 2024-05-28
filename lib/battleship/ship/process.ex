defmodule Battleship.Ship.Process do
  @moduledoc """
  This GenServer is used to encapsulate the state of
  a ship.
  """

  use GenServer, restart: :transient

  require Logger

  alias Battleship.Ship
  alias Battleship.Ship.Registry, as: ShipReg

  # +------------------------------------------------------------------+
  # |               GenServer Public API Functions                     |
  # +------------------------------------------------------------------+

  @doc """
  This function is used to start the GenServer.
  """
  def start_link(%Ship{id: ship_id} = ship) do
    GenServer.start_link(__MODULE__, ship, name: via_tuple(ship_id))
  end

  # +------------------------------------------------------------------+
  # |                 GenServer Callback Functions                     |
  # +------------------------------------------------------------------+

  @impl true
  def init(%Ship{} = ship) do
    {:ok, ship}
  end

  @impl true
  def handle_call(:get_ship_details, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:update_ship_details, ship_details}, _from, state) do
    updated_state = Map.merge(state, ship_details)
    {:reply, updated_state, updated_state}
  end

  def via_tuple(ship_id) do
    {:via, Registry, {ShipReg, ship_id}}
  end
end
