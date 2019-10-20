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
      socket = socket
      |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("select", %{"dot_id" => dot_id}, socket) do
    name = socket.assigns[:name]
    game = GameServer.select(name,dot_id)
    broadcast!(socket, "update", %{ "game" => Game.client_view(game) })
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
