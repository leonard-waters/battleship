defmodule Battleship do
  @moduledoc """
  This module handles starting the game.
  """
  use GenServer

  alias Battleship.CLI

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state, {:continue, :start_game}}
  end

  def handle_continue(:start_game, state) do
    CLI.print_instructions()
    {:noreply, state, {:continue, :continue_game}}
  end

  def handle_continue(:continue_game, state) do
    CLI.wait_for_input()
    {:noreply, state}
  end
end
