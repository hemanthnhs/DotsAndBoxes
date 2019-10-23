defmodule DotsAndBoxes.GameServer do
  use GenServer

  def reg(name) do
    {:via, Registry, {DotsAndBoxes.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker,
    }
    DotsAndBoxes.GameSup.start_child(spec)
  end

  def start_link(name) do
    game = DotsAndBoxes.BackupAgent.get(name) || DotsAndBoxes.Game.new(5, 5)
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def start_link(name, rows_num, cols_num, players_num) do
    game = DotsAndBoxes.BackupAgent.get(name) || DotsAndBoxes.Game.new(rows_num, cols_num, players_num)
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def select(name, dot_id, player_name) do
    GenServer.call(reg(name), {:select, name, dot_id, player_name})
  end

  def new_join(name, player_name) do
    GenServer.call(reg(name), {:new_join, name, player_name})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def init(game) do
    {:ok, game}
  end

  def begin_game(name) do
    GenServer.call(reg(name), {:begin_game, name})
  end

  def handle_call({:select, name, dot_id, player_name}, _from, game) do
    is_curr_player = DotsAndBoxes.Game.is_current_player(game, player_name)
    if is_curr_player do
      game = DotsAndBoxes.Game.select(game, dot_id)
      DotsAndBoxes.BackupAgent.put(name, game)
      {:reply, game, game}
    else
      {:noreply, game}
    end
  end

  def handle_call({:peek, _name}, _from, game) do
    {:reply, game, game}
  end

  def handle_call({:new_join, name, player_name}, _from, game) do
    game = DotsAndBoxes.Game.new_player(game, player_name)
    DotsAndBoxes.BackupAgent.put(name, game)
    {:reply, game, game}
  end

  def handle_call({:begin_game, name}, _from, game) do
    game = DotsAndBoxes.Game.begin_game(game)
    DotsAndBoxes.BackupAgent.put(name, game)
    {:reply, game, game}
  end
end