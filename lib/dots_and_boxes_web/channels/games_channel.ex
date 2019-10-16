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



  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
