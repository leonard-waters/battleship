defmodule Battleship.Ship.DynamicSupervisor do
  @moduledoc """
  This module is responsible for starting ship GenServers and
  then supervising them while the user interacts with the bulk sync
  operations from the cli.
  """

  use DynamicSupervisor

  alias Battleship.Ship
  alias Battleship.Ship.Process, as: ShipProcess

  @doc """
  This function is used to start the DynamicSupervisor in the supervision tree
  """
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Start a new ship process and adds it to the DynamicSupervisor.
  """
  def add_ship_to_supervisor(%Ship{} = ship) do
    child_spec = %{
      id: ShipProcess,
      start: {ShipProcess, :start_link, [ship]},
      restart: :transient
    }

    {:ok, _pid} = DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  @doc """
  Gets all of the PIDs under this DynamicSupervisor.
  """
  def all_ship_pids do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.reduce([], fn {_, ship_pid, _, _}, acc ->
      [ship_pid | acc]
    end)
  end

  def list_ships do
    __MODULE__.DynamicSupervisor.all_ship_pids()
    |> Enum.map(fn pid ->
      :sys.get_state(pid)
    end)
  end
end
