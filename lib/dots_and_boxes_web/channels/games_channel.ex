defmodule DotsAndBoxesWeb.GamesChannel do
  use DotsAndBoxesWeb, :channel

  alias DotsAndBoxes.Game
  alias DotsAndBoxes.BackupAgent
  alias DotsAndBoxes.GameServer

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      game = GameServer.peek(name)
      BackupAgent.put(name, game)
      player_name = socket.assigns[:player_name]
      game = GameServer.new_join(name, player_name)
      BackupAgent.put(name, game)
      socket = socket
               |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("notify", payload, socket) do
    name = socket.assigns[:name]
    game = GameServer.peek(name)
    broadcast!(socket, "update", %{"game" => Game.client_view(game)})
    {:noreply, socket}
  end

  def handle_in("select", %{"dot_id" => dot_id}, socket) do
    name = socket.assigns[:name]
    player_name = socket.assigns[:player_name]
    game = GameServer.select(name, dot_id, player_name)
    broadcast!(socket, "update", %{"game" => Game.client_view(game)})
    {:reply, {:ok, %{"game" => Game.client_view(game)}}, socket}
  end

  def handle_in("chat", %{"msg" => msg}, socket) do
    player_name = socket.assigns[:player_name]
    broadcast!(socket, "new_message", %{"player_name" => player_name, "msg" => msg})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
