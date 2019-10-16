defmodule DotsAndBoxes.Game do

  def new do
    %{
      rows: 5,
      cols: 5,
      dots: initialize_dots(5, 5),
      active_dot: 0,
      adjacent_dots: []
    }
  end

  def client_view(game) do
    %{
      rows: game.rows,
      cols: game.cols,
      dots: game.dots,
      active_dot: game.active_dot,
      adjacent_dots: game.adjacent_dots
    }
  end

  def initialize_dots(rows, cols) do
    num = rows * cols
    #Attribution https://inquisitivedeveloper.com/lwm-elixir-47/
    Map.new(1..num, fn n -> {n, []} end)
  end

  def select(game, dot_id) do
    if(game.active_dot == 0) do
      adjacent_dots = get_adjacent_dots(dot_id, game.rows, game.cols)
      %{game | active_dot: dot_id, adjacent_dots: adjacent_dots}
    else
      %{game | active_dot: 0, adjacent_dots: []}
    end
  end

  def get_adjacent_dots(dot_id, rows, cols) do
    max_dots = rows * cols
    {id, ""} = Integer.parse(dot_id)
    []
    |> add_to_list(rem(id, cols) != 1, [id - 1])
    |> add_to_list(rem(id, cols) != 0, [id + 1])
    |> add_to_list(id - rows > 0, [id - rows])
    |> add_to_list(id + rows < max_dots, [id + rows])
  end

  def add_to_list(list, cond, new) do
    #Attribution : https://elixirforum.com/t/creating-list-adding-elements-on-specific-conditions/6295/3
    if cond, do: new ++ list, else: list
  end

end
