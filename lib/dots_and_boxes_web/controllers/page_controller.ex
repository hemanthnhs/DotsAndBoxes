defmodule DotsAndBoxesWeb.PageController do
  use DotsAndBoxesWeb, :controller

  def index(conn, params) do
    render conn, "index.html", game_name: params["name"]
  end

  def game(conn, %{"game_name" => game_name, "player_name" => player_name}) do
    render conn, "game.html", game_name: game_name, player_name: player_name
  end
end
