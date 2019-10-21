defmodule DotsAndBoxesWeb.RoomsChannel do
  use DotsAndBoxesWeb, :channel

  alias DotsAndBoxes.Game

  def join("rooms:lobby", payload, socket) do
    {:ok, socket}
  end

  def handle_in("chat", %{"msg" => msg}, socket) do
    broadcast!(socket, "new_message", %{"msg" => msg})
    {:noreply, socket}

  end
end
