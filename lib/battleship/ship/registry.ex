defmodule Battleship.Ship.Registry do
  def child_spec do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__,
      partitions: System.schedulers_online()
    )
  end

  @doc """
  This function looks up a ship process by its ID so that the
  process can be then interacted with via its PID.
  """
  def lookup_ship(ship_id) do
    case Registry.lookup(__MODULE__, ship_id) do
      [{ship_pid, _}] ->
        {:ok, ship_pid}

      [] ->
        {:error, :not_found}
    end
  end

  # The below functions are used under the hood when leveraging :via
  # to process PID lookup through a registry.

  @doc false
  def whereis_name(ship_id) do
    case lookup_ship(ship_id) do
      {:ok, ship_id} -> ship_id
      _ -> :undefined
    end
  end
end
