defmodule DotsAndBoxesWeb.PageController do
  use DotsAndBoxesWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
