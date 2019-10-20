defmodule DotsAndBoxesWeb.PageController do
  use DotsAndBoxesWeb, :controller

  def index(conn, _params) do
    IO.puts "dddd"
    IO.inspect conn
    render(conn, "index.html")
  end

  def game(conn, %{"name" => name}) do
    render conn, "game.html", name: name
  end
end
