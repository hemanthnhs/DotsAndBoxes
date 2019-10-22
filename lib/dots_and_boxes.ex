defmodule DotsAndBoxes do
  alias DotsAndBoxes.GameServer
  alias DotsAndBoxes.BackupAgent

  @moduledoc """
  DotsAndBoxes keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def create_game(game_name, player_name, rows_num, cols_num, players_num) do
    GameServer.start_link(game_name, rows_num, cols_num, players_num)
    GameServer.new_join(game_name, player_name)
  end

  def check_game(game_name) do
    GameServer.new_join(game_name, "player_name")
  end
end
