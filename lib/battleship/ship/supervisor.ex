defmodule Battleship.Ship.Supervisor do
  @moduledoc """
  This supervisor starts all of the necessary components of the ship
  supervision tree (the registry, dynamic supervisor, and the initial state
  hydrator).
  """

  use Supervisor

  alias Battleship.Ship

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      Ship.Registry.child_spec(),
      Ship.DynamicSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
