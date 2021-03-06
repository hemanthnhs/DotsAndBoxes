﻿DOTS AND BOXES

Authors: Hemanth Sai Nimmala, Satya Sudheera Vytla

Game: We are planning to build ‘Dots and Boxes’ game. Dots and Boxes
is a multiplayer game which needs a minimum of 2 players. It is
typically a pencil-paper game that requires no additional setup. It is
a quick and easy to learn game while involving strategic mind play to
win. The game begins with a grid of unconnected dots. Each player take
turns to join the unconnected adjacent dots in the grid with the aim
of completing a box/square. The player who gets to join the last
unconnected adjacent dots that would complete a square unit would gain
one point and an extra turn. The actions made by the players in their
respective turns would impact each other and cannot be reversed at any
point in the game. The player with maximum points will be declared as
the winner at the end of the game.

Game Rules and Work: The game is well specified. All the rules and
requirements are well established for the game. To start the game, a
grid of unconnected dots with at minimum of 2 players would be
required. The grid can be of any M X N size matrix. The players can
only join the unconnected dots remaining in the grid. In every turn no
more than two dots can be connected, and the connection can be made
only between adjacent unconnected dots. Every time a player who
completes the fourth side of a square box earns a point and an extra
turn to play. Usually the point earned by the player is recorded by
placing the player’s initial/symbol in the box completed. The game
ends when all dots are connected. The winner is the player with more
points recorded on their initial. Since it is an online game, we would
like to incorporate a feature letting the player to pause the game at
any point and resume it later with preserved game state.

Additional game functionalities: We would like to include a factor of
luck into this game. The aim of the players which is to record more
boxes on their initial to maximize their score remains unchanged. To
turn this game slightly into a game of chance, we would like to
randomly hide a spin wheel behind few of the square boxes. The spin
wheel will be revealed in the game only when a player completes the
fourth side of the box where it is hidden. The player who completes
the hidden spin wheel square box gets to spin the wheel. The spin
wheel can giveaway rewards, negatives or can leave the game unchanged.
We plan to make the spin wheel with four to six wedges worth extra
points or negative points or zero points. The winner is the player who
is with maximum points at the end of the game.

Expected challenges: Since it is a turn-based multiplayer game, and
every action made by the players in their respective turns would have
effect on each other, the expectation is to have high responsiveness.
But generally, considering it’s a client-server architecture there are
good chances of encountering delays in the responsiveness to a
player’s action. This would impact a player’s perception of the game.
Therefore, there might arise a need to implement mechanisms to
compensate the lag. Few more challenges we anticipate is that the game
gives the player the luxury of time to make a move, but what if the
player takes really long time to decide their move or the player quits
the game while the game is still unfinished or the player loses
connection to the game. We would also like to have a solution for
differentiating between the scenario where player quits the game and
the scenario where player pauses the game to resume it later. We wish
to gracefully notify the players in such scenarios and address all of
them with an efficient solution.
