defmodule DotsAndBoxesWeb.PageController do
  use DotsAndBoxesWeb, :controller

  def index(conn, params) do
    render conn, "index.html", game_name: params["name"]
  end

  def game(conn, params) do
    game_name = params["game_name"]
    player_name = params["player_name"]
    game_create = params["create"]
    if (game_create=="true") do
      {rows_num,_} = Integer.parse(params["rows_num"])
      {cols_num,_} = Integer.parse(params["cols_num"])
      {players_num,_} = Integer.parse(params["players_num"])
      y = DotsAndBoxes.create_game(game_name, player_name, rows_num, cols_num,players_num)
      render conn, "game.html", game_name: game_name, player_name: player_name
    else
      render conn, "game.html", game_name: game_name, player_name: player_name
    end
  end
end
