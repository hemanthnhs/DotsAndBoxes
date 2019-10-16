defmodule DotsAndBoxes.Game do

def new do
%{
  rows: 5,
  cols: 5,
  dots: [1,2,3,4,5,6],
}
end

def client_view(game) do
  %{
    dots: game.dots,
  }
end

end
