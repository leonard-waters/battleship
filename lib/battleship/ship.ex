defmodule Battleship.Ship do
  @moduledoc """
  This module is used to house data related to a particular
  ship. It's primarily used by the ShipProcess GenServer to
  initialize its state.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          ship_class: String.t(),
          size: Integer.t(),
          sunk?: boolean(),
          hit_count: Integer.t(),
          direction: String.t(),
          position: String.t()
        }

  @enforce_keys [:id, :ship_class, :size, :direction, :position, :hit_count, :sunk?]
  defstruct [:id, :ship_class, :size, :direction, :position, :hit_count, :sunk?]

  alias Battleship.Ship.Registry, as: ShipReg

  require Logger

  @ship_class_size %{
    "carrier" => 5,
    "battleship" => 4,
    "cruiser" => 3,
    "submarine" => 3,
    "destroyer" => 2
  }

  @doc """
  Create a new instance of the struct
  """
  def new(ship_class, direction, position) do
    %__MODULE__{
      id: generate_id(),
      ship_class: ship_class,
      size: @ship_class_size[ship_class],
      direction: direction,
      position: position,
      hit_count: 0,
      sunk?: false
    }
  end

  @doc """
  This function will fetch the details from a ship process.
  """
  def get_ship_details(ship_id) do
    try do
      GenServer.call(via_tuple(ship_id), :get_ship_details)
    catch
      :exit, _reason ->
        {:error, :not_found}
    end
  end

  @doc """
  This function will update the ship details from a ship process.
  """
  def update_ship(ship_id, updated_details) do
    try do
      GenServer.call(via_tuple(ship_id), {:update_ship_details, updated_details})
    catch
      :exit, _reason ->
        {:error, :not_found}
    end
  end

  def via_tuple(ship_id) do
    {:via, ShipReg, ship_id}
  end

  def list_ships do
    __MODULE__.DynamicSupervisor.all_ship_pids()
    |> Enum.map(fn pid ->
      :sys.get_state(pid)
    end)
  end

  def ship_class_and_size do
    @ship_class_size
  end

  defp generate_id do
    list_ships()
    |> Enum.count()
    |> Kernel.+(1)
    |> Integer.to_string()
  end
end
