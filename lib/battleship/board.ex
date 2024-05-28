defmodule Battleship.Board do
  alias Battleship.Ship
  alias Battleship.Board.Coordinate
  alias Battleship.Board.CoordinateDynamicSupervisor

  def place_ship([ship_class, direction, position]) do
    with %Ship{} = new_ship <- Ship.new(ship_class, direction, position),
         {:ok, _pid} <- Ship.DynamicSupervisor.add_ship_to_supervisor(new_ship),
         %Ship{} = _ship <- Ship.get_ship_details(new_ship.id),
         :ok <- add_coordinates(new_ship, position, direction) do
      new_ship
    end
  end

  def fire([coordinate]) do
    case Coordinate.get_coordinate_details(coordinate) do
      %Coordinate{hit?: true} -> :already_hit
      {:error, :not_found} -> :miss
      coordinate_details -> hit_or_sunk(coordinate_details)
    end
  end

  defp hit_or_sunk(%{ship_id: ship_id} = coordinate) do
    with %Ship{} = ship <- Ship.get_ship_details(ship_id),
         %Ship{} = ship <- increment_and_update_hits(ship),
         %Coordinate{} = _coordinate <- update_coordinate(coordinate) do
      if ship.size == ship.hit_count, do: {:sunk, ship.ship_class}, else: :hit
    end
  end

  defp increment_and_update_hits(ship) do
    Ship.update_ship(ship.id, %{hit_count: ship.hit_count + 1})
  end

  defp update_coordinate(coord) do
    Coordinate.update_coordinate(coord.id, %{hit?: true})
  end

  defp add_coordinates(ship, position, "down") do
    size = Ship.ship_class_and_size() |> Map.get(ship.ship_class)
    available_rows = Coordinate.allowed_rows()
    [row | column] = String.graphemes(position)

    row_start_index = Enum.find_index(available_rows, &(&1 == row))
    row_end_index = row_start_index + size

    _new_coords =
      available_rows
      |> Enum.slice(row_start_index..row_end_index)
      |> Enum.map(fn row ->
        coordinate_id = "#{row}#{Enum.join(column)}"

        %Coordinate{} = coordinate = Coordinate.new(coordinate_id, ship.id)

        {:ok, _pid} = CoordinateDynamicSupervisor.add_coordinate_to_supervisor(coordinate)
      end)

    :ok
  end

  defp add_coordinates(%{id: ship_id, ship_class: ship_class}, position, "right") do
    size = Ship.ship_class_and_size() |> Map.get(ship_class)
    row = String.at(position, 0)
    col = String.slice(position, 1..2) |> String.to_integer()

    _new_coords =
      Enum.each(0..size, fn num ->
        coordinate_id = "#{row}#{num + col}"

        %Coordinate{} = coordinate = Coordinate.new(coordinate_id, ship_id)

        {:ok, _pid} = CoordinateDynamicSupervisor.add_coordinate_to_supervisor(coordinate)
      end)

    :ok
  end

  def game_over? do
    Battleship.Ship.list_ships()
    |> Enum.reduce(
      0,
      fn
        %{sunk?: true}, acc -> acc + 1
        _, acc -> acc
      end
    )
    |> IO.inspect()
    |> then(fn ships_sunk -> ships_sunk == 5 end)
  end
end
