defmodule Battleship.Board.CoordinateSupervisor do
  @moduledoc """
  This supervisor starts all of the necessary components of the coordinate
  supervision tree (the registry and dynamic supervisor).
  """

  use Supervisor

  alias Battleship.Board.{CoordinateDynamicSupervisor, CoordinateRegistry}

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      CoordinateRegistry.child_spec(),
      CoordinateDynamicSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
