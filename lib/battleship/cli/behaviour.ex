defmodule Battleship.CLI.Behaviour do
  @callback print_message(String.t()) :: :ok
  @callback place_ship() :: {String.t(), String.t(), String.t()} | :error
  @callback fire(String.t()) :: String.t() | nil
end
