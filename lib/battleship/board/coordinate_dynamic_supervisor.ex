defmodule Battleship.Board.CoordinateDynamicSupervisor do
  @moduledoc """
  This module is responsible for starting Coordinate GenServers and
  then supervising them while the user interacts with the bulk sync
  operations from the CLI.
  """

  use DynamicSupervisor

  alias Battleship.Board.{Coordinate, CoordinateProcess}

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
  Start a new coordinate process and adds it to the DynamicSupervisor.
  """
  def add_coordinate_to_supervisor(%Coordinate{} = coord) do
    child_spec = %{
      id: CoordinateProcess,
      start: {CoordinateProcess, :start_link, [coord]},
      restart: :transient
    }

    {:ok, _pid} = DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
