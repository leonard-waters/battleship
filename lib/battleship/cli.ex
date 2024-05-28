defmodule Battleship.CLI do
  # @behaviour Battleship.CLI.Behaviour

  # @background_color 53
  # @hit_color 15
  # @miss_color 183

  alias Battleship.CLI.Rules

  @col_range 1..10
  @row_range ~W(A B C D E F G H I J)

  @game_over_message """
  ************************************************
  ************************************************
                     GAME OVER
  ************************************************
  ************************************************
  """

  @instructions_message """
  \n\n
  ************************************************
  ************************************************
                     BATTLESHIP
  ************************************************
  ************************************************

  Welcome to war commander! Your fleet awaits!

  Instructions:
  1. First you will need to place your fleet:
    - your fleet has one ship of each ship class (this is the size of the ship):
      - carrier (5)
      - battleship (4)
      - cruiser (3)
      - submarine (3)
      - destroyer (2)
    - each ship will be oriented down or right of a specified position/coordinate
    - place your fleet by typing the "PLACE_SHIP {ship_class} {direction} {position} and then hitting enter"
    - for example "PLACE SHIP battleship down A1"
  2. Once your fleet is deployed you can begin firing!
    - fire at the ships by typing "FIRE {position}"
  3. Keep firing until all five ships are destroyed.

  Here is the game board to help you decide how to deploy your fleet:\n\n
  """

  def print_instructions do
    IO.write(@instructions_message)
    draw_board(:init)

    IO.write(IO.ANSI.reset())

    IO.puts("\n You may now input commands: \n\n")
  end

  def wait_for_input do
    IO.puts("\nPlease input a command: \n\n")

    :line
    |> IO.read()
    |> String.trim()
    |> String.split(" ")
    |> Rules.validate_command()
    |> then(fn
      {:ok, ["PLACE_SHIP" | input]} ->
        ship = Battleship.Board.place_ship(input)
        IO.write("\nPlaced #{ship.ship_class}\n\n")

      {:ok, ["FIRE" | input]} ->
        case Battleship.Board.fire(input) do
          {:sunk, ship_class} ->
            msg =
              if Battleship.Board.game_over?(),
                do: @game_over_message,
                else: "\nYou sunk my #{ship_class}!\n\n"

            IO.write(msg)

          :hit ->
            IO.write("\nHIT!\n\n")

          :miss ->
            IO.write("\nMISS!\n\n")

          :already_hit ->
            IO.write("\nAlready hit, fire again!\n\n")
        end

      {:error, :invalid_position} ->
        IO.write("\nInvalid ship placement, position is not on the board\n\n")

      {:error, :invalid_ship_class} ->
        IO.write("\nInvalid ship class\n\n")

      {:error, :position_occupied} ->
        IO.write("\nInvalid ship placement, there's already a ship positioned there.\n\n")

      {:error, :invalid_position_edge} ->
        IO.write("\nInvalid ship placement, this position is too close the edge of the board.\n\n")

      {:error, :invalid_direction} ->
        IO.write("\nInvalid ship direction.\n\n")

      {:error, :invalid_command} ->
        IO.write("\nInvalid command.\n\n")

      {:error, reason} ->
        IO.write("\n#{reason}\n\n")
    end)

    wait_for_input()
  end

  def draw_board(:init) do
    print_header_columns() |> IO.write()
    print_rows() |> IO.write()
  end

  def print_header_columns do
    Enum.reduce(@col_range, "\n   ", fn num, acc ->
      IO.ANSI.underline() <> "#{acc}" <> "| #{num} "
    end)
  end

  def print_rows do
    for row <- @row_range do
      Enum.reduce(@col_range, "\n #{row}", fn _num, acc ->
        IO.ANSI.underline() <> "#{acc} " <> "|  "
      end) <> " |"
    end
  end
end
