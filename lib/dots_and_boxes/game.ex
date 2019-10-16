defmodule DotsAndBoxes.Game do

  def new do
    %{
      rows: 5,
      cols: 5,
      dots: initialize_dots(5,5),
      active_dot: 0
    }
  end

  def client_view(game) do
    %{
      rows: game.rows,
      cols: game.cols,
      dots: game.dots,
      active_dot: game.active_dot
    }
  end

  def initialize_dots(rows, cols) do
    num = rows * cols
    #Attribution https://inquisitivedeveloper.com/lwm-elixir-47/
    Map.new(1..num, fn n -> {n, []} end)
  end

end
