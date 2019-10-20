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
    game = DotsAndBoxes.BackupAgent.get(name) || DotsAndBoxes.Game.new()
    IO.puts("here start")
    GenServer.start_link(__MODULE__, game, name: reg(name))
  end

  def select(name, dot_id) do
    IO.puts("here genserver")
    GenServer.call(reg(name), {:select, name, dot_id})
  end

  def peek(name) do
    GenServer.call(reg(name), {:peek, name})
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:select, name, dot_id}, _from, game) do
    IO.puts("reply")
    game = DotsAndBoxes.Game.select(game, dot_id)
    DotsAndBoxes.BackupAgent.put(name, game)
    {:reply, game, game}
  end

 def handle_call({:peek, _name}, _from, game) do
   {:reply, game, game}
 end

end