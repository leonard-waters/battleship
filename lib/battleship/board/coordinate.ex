defmodule Battleship.Board.Coordinate do
  @moduledoc """
  This module is used to house data related to a particular
  ship. It's primarily used by the BoardProcess GenServer to
  initialize its state.
  """

  @type t :: %__MODULE__{
          id: String.t(),
          ship_id: String.t(),
          hit?: boolean()
        }

  @enforce_keys [:id, :ship_id, :hit?]
  defstruct [:id, :ship_id, :hit?]

  alias Battleship.Board.CoordinateRegistry

  require Logger

  @col_range 1..10
  @row_range ~W(A B C D E F G H I J)

  @doc """
  Create a new instance of the struct
  """
  def new(coordinate_id, ship_id) do
    %__MODULE__{
      id: coordinate_id,
      ship_id: ship_id,
      hit?: false
    }
  end

  @doc """
  This function will fetch the details from a board process.
  """
  def get_coordinate_details(coordinate_id) do
    try do
      GenServer.call(via_tuple(coordinate_id), :get_coordinate_details)
    catch
      :exit, _reason ->
        {:error, :not_found}
    end
  end

  @doc """
  This function will update the coordinate details from a coordinate process.
  """
  def update_coordinate(coordinate_id, updated_details) do
    try do
      GenServer.call(via_tuple(coordinate_id), {:update_coordinate_details, updated_details})
    catch
      :exit, _reason ->
        {:error, :not_found}
    end
  end

  def via_tuple(coordinate_id) do
    {:via, CoordinateRegistry, coordinate_id}
  end

  def allowed_coordinates, do: for(row <- @row_range, col <- @col_range, do: "#{row}#{col}")

  def allowed_rows, do: @row_range
end
