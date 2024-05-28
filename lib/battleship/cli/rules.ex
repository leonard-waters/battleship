defmodule Battleship.CLI.Rules do
  @moduledoc """
  This module handles applying the rules to user commands.
  """
  alias Battleship.Ship
  alias Battleship.Board.Coordinate

  @directions ~w(down right)

  def validate_command(["PLACE_SHIP", ship_class, direction, position] = input) do
    with :ok <- validate_ship_class(ship_class),
         # :ok <- validate_ship_not_placed(ship_class),
         :ok <- validate_direction(direction),
         :ok <- validate_position_empty(position),
         :ok <- validate_position(direction, ship_class, position) do
      {:ok, input}
    end
  end

  def validate_command(["FIRE" | attack_details] = input) do
    if valid_coordinate?(attack_details |> hd()),
      do: {:ok, input},
      else: {:error, :invalid_position}
  end

  def validate_command(_invalid_command) do
    {:error, :invalid_command}
  end

  defp validate_ship_class(ship_class) do
    if Enum.any?(Ship.ship_class_and_size(), fn {class, _size} ->
         class == String.downcase(ship_class)
       end),
       do: :ok,
       else: {:error, :invalid_ship_class}
  end

  defp validate_direction(direction) do
    if Enum.member?(@directions, String.downcase(direction)),
      do: :ok,
      else: {:error, :invalid_direction}
  end

  defp validate_position_empty(position) do
    if Coordinate.get_coordinate_details(position) == {:error, :not_found},
      do: :ok,
      else: {:error, :position_occupied}
  end

  # TODO: Finish this
  # defp validate_ship_not_placed(ship_class) do
  # end

  def validate_position(direction, ship_class, position) do
    with true <- valid_coordinate?(position),
         :ok <- valid_direction_for_ship?(direction, position, ship_class) do
      :ok
    end
  end

  defp valid_coordinate?(position), do: position in Coordinate.allowed_coordinates()

  defp valid_direction_for_ship?("down", position, ship_class) do
    size = Ship.ship_class_and_size() |> Map.get(ship_class)
    available_rows = Coordinate.allowed_rows()
    [row | _column] = String.graphemes(position)
    row_index = Enum.find_index(available_rows, &(&1 == row)) - 1
    if Enum.at(available_rows, row_index + size), do: :ok, else: {:error, :invalid_position_edge}
  end

  defp valid_direction_for_ship?("right", position, ship_class) do
    size = Ship.ship_class_and_size() |> Map.get(ship_class)

    last_col =
      String.slice(position, 1..2) |> String.to_integer() |> Kernel.+(size) |> Kernel.-(1)

    if last_col <= 10, do: :ok, else: {:error, :invalid_position_edge}
  end
end
