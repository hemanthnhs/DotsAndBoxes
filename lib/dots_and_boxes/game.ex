defmodule DotsAndBoxes.Game do

  def new_game_config do
    %{
      num_of_players: 2,
      players: %{},
      spectate: MapSet.new(),
      curr_player: 1,
      start: false,
      winner: false
    }
  end

  def new_player(game, player_name) do
    game_config = game.game_config
    players = game_config.players
    spectate = game_config.spectate
    len = map_size(players)
    if (Enum.member?(Map.values(players), player_name)) do
      game
    else
      if (len < game_config.num_of_players) do
        players = Map.put(players, len + 1, player_name)
        if(len == game_config.num_of_players - 1) do
          game_config = %{game_config | players: players, start: true}
          %{game | game_config: game_config}
        else
          game_config = %{game_config | players: players}
          %{game | game_config: game_config}
        end
      else
        spectate = MapSet.put(spectate, player_name)
        game_config = %{game_config | spectate: spectate}
        %{game | game_config: game_config}
      end
    end
  end

  def new do
    %{
      rows: 5,
      cols: 5,
      dots: initialize_dots(5, 5),
      previous_dot: 0,
      active_dot: 0,
      adjacent_dots: [],
      boxes: initialize_boxes(2),
      completed_dots: [],
      game_config: new_game_config(),
    }
  end

  def player_turn(game_config) do
    curr_player = game_config.curr_player
    if (curr_player == game_config.num_of_players) do
      curr_player = 1
      %{game_config | curr_player: curr_player}
    else
      curr_player = curr_player + 1
      %{game_config | curr_player: curr_player}
    end
  end

  def is_current_player(game, player_name) do
    players = game.game_config.players
    if (Map.get(players, game.game_config.curr_player) == player_name) do
      true
    else
      false
    end
  end

  def client_game_config(game_config) do
    players = game_config.players
    spectate = game_config.spectate
    current_player = Map.get(players, game_config.curr_player)
    %{game_config | players: Map.values(players), spectate: MapSet.to_list(spectate), curr_player: current_player}
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
      game_config: client_game_config(game.game_config),
    }
  end

  def initialize_dots(rows, cols) do
    num = rows * cols
    #Attribution https://inquisitivedeveloper.com/lwm-elixir-47/
    Map.new(1..num, fn n -> {n, []} end)
  end

  def initialize_boxes(num_of_players) do
    #Attribution https://inquisitivedeveloper.com/lwm-elixir-47/
    Map.new(1..num_of_players, fn n -> {n, []} end)
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
        boxes = check_and_create_boxes(
          game.game_config.curr_player,
          dot_id,
          game.previous_dot,
          game.dots,
          game.rows,
          game.boxes
        )
        completed_dots = update_completed(
          game.completed_dots,
          dot_id,
          game.previous_dot,
          game.rows,
          game.cols,
          Map.get(dots, dot_id),
          Map.get(dots, game.previous_dot)
        )
        game_config = player_turn(game.game_config)
        %{
          game |
          dots: dots,
          active_dot: 0,
          adjacent_dots: [],
          boxes: boxes,
          completed_dots: completed_dots,
          game_config: game_config
        }
      (true) ->
        game
    end
  end

  def update_completed(completed_dots, curr_dot, prev_dot, rows, cols, curr_dot_connections, prev_dot_connections) do
    adjacent_dots_for_current = get_adjacent_dots(curr_dot, rows, cols, curr_dot_connections)
    adjacent_dots_for_previous = get_adjacent_dots(prev_dot, rows, cols, prev_dot_connections)
    completed_dots
    |> add_to_list(length(adjacent_dots_for_current) == 0, [curr_dot])
    |> add_to_list(length(adjacent_dots_for_previous) == 0, [prev_dot])
  end

  def check_and_create_boxes(player_id, curr_dot, prev_dot, dots, rows, boxes) do
    # TODO one side of box already done
    #    dots = game.dots
    #    dots = Map.update(dots, dot_id, [], &([game.previous_dot | &1]))
    #    dots = Map.update(dots, game.previous_dot, [], &([dot_id | &1]))
    current_boxes = Map.get(boxes, player_id)
    if (abs(curr_dot - prev_dot) == 1) do
      #      Line is horizontal
      #      Check for boxes up or down
      current_boxes = add_to_list(current_boxes,
           (Enum.member?(dots[curr_dot], curr_dot - rows) and Enum.member?(dots[prev_dot], prev_dot - rows)
            and Enum.member?(dots[prev_dot - rows], curr_dot - rows)
             ),
           [Enum.sort([curr_dot, prev_dot, curr_dot - rows, prev_dot - rows])]
         )
      current_boxes = add_to_list( current_boxes,
           (
             Enum.member?(dots[curr_dot], curr_dot + rows) and Enum.member?(dots[prev_dot], prev_dot + rows)
             and Enum.member?(dots[prev_dot + rows], curr_dot + rows)
             ),
           [Enum.sort([curr_dot, prev_dot, curr_dot + rows, prev_dot + rows])]
         )
      boxes = Map.put(boxes, player_id, current_boxes)
      boxes
    else
      #    Line is vertical
      #    Check for boxes on right and left
      current_boxes = add_to_list(current_boxes,
           (
             Enum.member?(dots[curr_dot], curr_dot - 1) and Enum.member?(dots[prev_dot], prev_dot - 1)
             and Enum.member?(dots[prev_dot - 1], curr_dot - 1)
             ),
           [Enum.sort([curr_dot, prev_dot, curr_dot - 1, prev_dot - 1])]
         )
      current_boxes = add_to_list(current_boxes,
           (
             Enum.member?(dots[curr_dot], curr_dot + 1) and Enum.member?(dots[prev_dot], prev_dot + 1)
             and Enum.member?(dots[prev_dot + 1], curr_dot + 1)
             ),
           [Enum.sort([curr_dot, prev_dot, curr_dot + 1, prev_dot + 1])]
         )
      boxes = Map.put(boxes, player_id, current_boxes)
      boxes
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
