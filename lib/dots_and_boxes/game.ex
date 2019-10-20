defmodule DotsAndBoxes.Game do

  def new do
    %{
      rows: 5,
      cols: 5,
      dots: initialize_dots(5, 5),
      previous_dot: 0,
      active_dot: 0,
      adjacent_dots: [],
      boxes: [],
      completed_dots: []
    }
  end

  def client_view(game) do
    %{
      rows: game.rows,
      cols: game.cols,
      dots: game.dots,
      previous_dot: game.previous_dot,
      active_dot: game.active_dot,
      adjacent_dots: game.adjacent_dots,
      boxes: game.boxes,
      completed_dots: game.completed_dots,
    }
  end

  def initialize_dots(rows, cols) do
    num = rows * cols
    #Attribution https://inquisitivedeveloper.com/lwm-elixir-47/
    Map.new(1..num, fn n -> {n, []} end)
  end

  def select(game, dot_id) do
    #    4 Conditions
    #    1. No active
    #    2. Remove current active
    #    3. Adjacent clicked
    #    4. Reject other clicks than adjacent
    cond do
      (game.active_dot == 0) ->
        adjacent_dots = get_adjacent_dots(dot_id, game.rows, game.cols, Map.get(game.dots, dot_id))
        %{game | active_dot: dot_id, adjacent_dots: adjacent_dots, previous_dot: dot_id}
      (game.active_dot == dot_id) ->
        %{game | active_dot: 0, adjacent_dots: []}
      (Enum.member?(game.adjacent_dots, dot_id)) ->
        # Reference for update https://elixirforum.com/t/updating-a-maps-values-that-are-lists/15670/5
        dots = game.dots
        dots = Map.update(dots, dot_id, [], &([game.previous_dot | &1]))
        dots = Map.update(dots, game.previous_dot, [], &([dot_id | &1]))
        boxes = check_and_create_boxes(dot_id, game.previous_dot, game.dots, game.rows, game.boxes)
        completed_dots = update_completed(
          game.completed_dots,
          dot_id,
          game.previous_dot,
          game.rows,
          game.cols,
          Map.get(dots, dot_id),
          Map.get(dots, game.previous_dot)
        )
        %{game | dots: dots, active_dot: 0, adjacent_dots: [], boxes: boxes, completed_dots: completed_dots}
      (true) ->
        game
    end
  end

  def update_completed(completed_dots, curr_dot, prev_dot, rows, cols, curr_dot_connections, prev_dot_connections) do
    adjacent_dots_for_current = get_adjacent_dots(curr_dot, rows, cols, curr_dot_connections)
    adjacent_dots_for_previous = get_adjacent_dots(prev_dot, rows, cols, prev_dot_connections)
    IO.puts("===================")
    IO.puts(length(adjacent_dots_for_current))
    IO.puts(length(adjacent_dots_for_previous))
    completed_dots
    |> add_to_list(length(adjacent_dots_for_current) == 0, [curr_dot])
    |> add_to_list(length(adjacent_dots_for_previous) == 0, [prev_dot])
  end

  def check_and_create_boxes(curr_dot, prev_dot, dots, rows, boxes) do
    # TODO one side of box already done
    if (abs(curr_dot - prev_dot) == 1) do
      #      Line is horizontal
      #      Check for boxes up or down
      boxes
      |> add_to_list(
           (Enum.member?(dots[curr_dot], curr_dot - rows) and Enum.member?(dots[prev_dot], prev_dot - rows)
            and Enum.member?(dots[prev_dot - rows], curr_dot - rows)
             ),
           [Enum.sort([curr_dot, prev_dot, curr_dot - rows, prev_dot - rows])]
         )
      |> add_to_list(
           (
             Enum.member?(dots[curr_dot], curr_dot + rows) and Enum.member?(dots[prev_dot], prev_dot + rows)
             and Enum.member?(dots[prev_dot + rows], curr_dot + rows)
             ),
           [Enum.sort([curr_dot, prev_dot, curr_dot + rows, prev_dot + rows])]
         )
    else
      #    Line is vertical
      #    Check for boxes on right and left
      boxes
      |> add_to_list(
           (
             Enum.member?(dots[curr_dot], curr_dot - 1) and Enum.member?(dots[prev_dot], prev_dot - 1)
             and Enum.member?(dots[prev_dot - 1], curr_dot - 1)
             ),
           [Enum.sort([curr_dot, prev_dot, curr_dot - 1, prev_dot - 1])]
         )
      |> add_to_list(
           (
             Enum.member?(dots[curr_dot], curr_dot + 1) and Enum.member?(dots[prev_dot], prev_dot + 1)
             and Enum.member?(dots[prev_dot + 1], curr_dot + 1)
             ),
           [Enum.sort([curr_dot, prev_dot, curr_dot + 1, prev_dot + 1])]
         )
    end
  end

  def get_adjacent_dots(dot_id, rows, cols, completed_dots) do
    max_dots = rows * cols
    id = dot_id
    []
    |> add_to_list((rem(id, cols) != 1) and (!Enum.member?(completed_dots, id - 1)), [id - 1])
    |> add_to_list((rem(id, cols) != 0) and (!Enum.member?(completed_dots, id + 1)), [id + 1])
    |> add_to_list((id - rows > 0) and (!Enum.member?(completed_dots, id - rows)), [id - rows])
    |> add_to_list((id + rows < max_dots) and (!Enum.member?(completed_dots, id + rows)), [id + rows])
  end

  def add_to_list(list, cond, new) do
    #Attribution : https://elixirforum.com/t/creating-list-adding-elements-on-specific-conditions/6295/3
    if cond, do: new ++ list, else: list
  end

end
