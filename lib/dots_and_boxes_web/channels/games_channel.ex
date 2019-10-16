defmodule DotsAndBoxesWeb.GamesChannel do
  use DotsAndBoxesWeb, :channel

  alias DotsAndBoxes.Game

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      game = Game.new()
      socket = socket
      |> assign(:game, game)
      |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("select", %{"dot_id" => dot_id}, socket) do
    name = socket.assigns[:name]
    game = Game.select(socket.assigns[:game],dot_id)
    socket = assign(socket, :game, game)
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
