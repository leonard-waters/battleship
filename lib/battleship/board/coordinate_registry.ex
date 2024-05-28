defmodule Battleship.Board.CoordinateRegistry do
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
  def lookup_ship(coordinate_id) do
    case Registry.lookup(__MODULE__, coordinate_id) do
      [{coordinate_pid, _}] ->
        {:ok, coordinate_pid}

      [] ->
        {:error, :not_found}
    end
  end

  # The below functions are used under the hood when leveraging :via
  # to process PID lookup through a registry.

  @doc false
  def whereis_name(coordinate_id) do
    case lookup_ship(coordinate_id) do
      {:ok, coordinate_id} -> coordinate_id
      _ -> :undefined
    end
  end
end
