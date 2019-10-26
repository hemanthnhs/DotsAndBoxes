DOTS AND BOXES

Authors : Hemanth Sai Nimmala, Satya Sudheera Vytla

Introduction and Game Description

The game we built is very popularly known as ‘Dots and Boxes’. The
game is developed using Elixir, Phoenix and React framework which is
discussed in the coming sections. Dots and Boxes is a multiplayer game
which needs a minimum of two players. It is typically a pencil-paper
game that requires no additional setup. It is a quick and easy to
learn game while involving strategic mind play to win. The game begins
with a grid of unconnected dots. Each player takes turns to join the
unconnected adjacent dots in the grid with the aim of completing a
box/square. The player who gets to join the last unconnected adjacent
dots that would complete a square unit would gain one point and an
extra turn. The current scores of every player is displayed. The
actions made by the players in their respective turns would impact
each other and cannot be reversed at any point in the game. The player
with maximum points will be declared as the winner at the end of the
game.

The game enforces a minimum of 3X3 grid size and minimum of two
players. We support up to 8X8 grid size of dots and number of players
up to four. A player can create a new game with customizable
dimensions of Dots grid and two to four number of players can
participate in the game. The player who creates the game will be the
host throughout the game. Once the host joins the created game, a link
will be provided to invite the rest of the players to join the game.
The players can join the game using the link or the game name and when
the required number of players join the game, the host can start the
game. 
Once the required number of players join the game, any number of
spectators can join the game using the same link or the game name to
watch the players play the game. While we are restricting the number
of players who can play the game, there can be any number of
spectators who can join and watch the game. There is a chat room
provided for the players and spectators to interact with each other
through texts.

Each player is given an icon to represent their scores and the boxes
recorded on their name. The game ends when all the dots are connected.
The winner will be declared. The players are given their final scores
and an option to restart the game.
 
UI Design

To implement our UI we made use of Bootstrap framework. The first page
of our game provides 2 options for the user – Create a new game or
Join an existing game. To create a new game, the user is provided with
drop down to choose the grid dimensions and number of players the game
should have. There is a wait screen put up along with an unmodifiable
link using which players and spectators can join the game. Until all
the required number of players join the game, the start game button is
disabled for the host. Once all the players join in, the host can
start the game. Few details such as the name of the game, the name of
the game host and the player’s name is displayed in the NavBar on top
of the screen. The screen has two major areas - play area and a chat
area. 

In the play area, we made use of React-Konva to draw the dots
and let players draw lines to connect the unconnected dots. To enhance
user experience, we used various colors to differentiate between the
selected dot by the player to connect and its adjacent possible dots
to which it can be connected with. The line drawn by the player to
join dots is also colored upto a certain length on extension,
indicating a player the possible connections range. The line’s start
and end coordinates drawn by the user are stored in the game state.
The coordinates of the lines drawn by the player after clicking on the
dot are obtained using onMouseMove event. Once a valid connection of
dots is made the line is given a different color to indicate its
validity to the player. Since it is a turn-based game, all the players
are notified about which player’s turn is running in the game using a
text mentioning whose turn at the bottom of the screen and two colors
to differentiate between their turn and other player’s turn.  The
current scores of all the players is displayed next to the turn
indicating field at the bottom of the screen. Each player is given an
icon to represent their boxes recorded on their name and the icon is
displayed upon completion of a square by the player. Once the game is
completed the play area displays the winner of the game, scorecard and
an option to restart the game.

In the chat area, the players and spectators can interact with each
other by typing a message in the text field provided and hit submit
button. And every text message is tracked on the name of the person
who posted it and is displayed along with the text message posted. The
submit button remains disabled until a text is entered.

UI to Server Protocol

The server-side logic of the game has been developed using Elixir and
Phoenix. To establish communication to the server we made use of
Phoenix channels. To start communicating with the server, the
constructor in React component sends join request to the server. If
the join request is successful, the server acknowledges the request
with a reply ok. The host can begin the game only when all the
required number of players join the channel with the same game name
subtopic. In order to notify the host as well as other players who are
already connected on the channel about a new player joining the
channel, a handle_in method in the channel is created to broadcast the
new game state to all the players of the game and thereby enabling the
start game button for the host to begin the game.

The player(client) listens for the “update” event using channel.on for
notifications when there are new incoming players and when the game
state is updated. The player also listens for the “new_message” event
using channel.on for receiving messages that are broadcast from other
players. The handle_in methods in the server broadcasts updates to all
the clients by pattern matching on the event names received from the
clients. Our handle_in methods does pattern matching on various events
like notify to notify all players about an incoming new player, update
to update all players with latest game state, begin_game to let all
users see a new game, restart_game to update users with new game, chat
to broadcast a text message to all the players and spectators. With
all the event handlers and communication establishment in place, once
the game begins, the player clicks on the dot to join it with an
adjacent dot, an event is raised on UI side to communicate the action
performed by the player to the server through the channel. The server
with the information received computes the valid adjacent dots the
player can connect to, computes whether the player should get an extra
turn, updates the score if required. The computed information is
updated in the state object and communicates it back to the UI. In the
UI, the player is indicated with the valid connections possible,
current score details, turn running in the game etc. Upon game
completion, the players are provided with restart option. When a
player hits restart, an event is raised on the UI side to communicate
the game restart message through the channel to the server. The server
initializes the game board and the scores and broadcasts the new game
to all the connected clients (players and spectators).

The chat area in the UI as discussed earlier, is used to communicate
to other connected clients (players and spectators) through texts.
When a client sends a text, based on the topic all the existing
clients connected on the channel receive the text sent. The whole game
logic is run in the server and it updates the game state and
communicates the same via channels to the clients.

Data structures on server

The game state maintained has a Map data structure for holding the
information about the dots and their connections. A map represents the
information in the form of key-value pairs. To represent our
information about the dots and their connections, every dot is given
an id which becomes a key in the Map. The value mapped to each key is
in turn a list data structure which holds all the Dot IDs the key dot
is connected to. This way when the player attempts to make a
connection between dots, we can always look up if the connection is
already made or not. 

Similarly, a map is used to keep track of the
boxes completed by each player. The key is the player id and the value
is a list of dots that are joined to form the box. When a player
clicks on a dot to start connecting it with another, we show the
player what are the valid connections possible using few colors. To
achieve this, a list is maintained to only track completed dots. The
lookup would become easier to check which dots are left unconnected.

To maintain the scores of each player, a map is used where the key is
the player ID and the value is the score gained by the player. Some
data related to game configuration such as number of rows and columns
in the grid, number of players and spectators, if the game has begun,
whose turn running in the game and the game winner(s) are maintained
under game_config map object. The start and winner are initially set
to false. But once the game is begun by the host, the start is set to
true and once the game has finished, winner would hold the game data
as a map comprising additional information such as if the game has
ended up in a tie or more than one player has emerged as winners out
of multiple players. The game has users who can play and spectators
who can only chat and watch the game. The first number of required
users who join the game are considered as players and rest incoming
users are considered as spectators. The players are stored in a Map
with key as player ID and value as the player name. While the
spectators are stored in a set as we aren’t concerned about their IDs
to let them watch the game or display their text messages. All of this
information is stored in game_config map object which is nested in the
game state. The reason to nest this inside the game state is that when
the player chooses to restart the game we can create a new game object
with the rows, columns details and use the same list of players,
spectators as in game_config map.  

Implementation of game rules 

All the rules and requirements are well established for the game. The game
enforces a minimum of two players and allows up to four players. This
rule is implemented by providing the user with a drop down to pick
from the available options.To begin the game, along with the players
there needs to be a grid of unconnected dots. The grid size cannot go
less than 3X3 dimensional grid size and we support up to 8X8
dimensional grid of dots by providing the user with a drop down to
pick from the available options.  
The game works as follows : 
When the player clicks on a dot, the server computes what are the valid
connections possible from the dot clicked by computing its adjacent
unconnected dots, updates the game state and communicates back to the
UI to display for the user.

When the second dot is clicked to complete the line, the server checks
if the line drawn by the user is valid. The server validates by
checking the presence of the current dot clicked in the valid adjacent
dots possible for the previously clicked dot. If the player performs a
valid action then the server updates the game state with joined dots
or else the player’s action is ignored.

The player’s aim is to score points by finishing the fourth side of a
box. To check if a box/square is complete, the logic was to understand
the type of line being drawn by the player - horizontal or vertical.
If a horizontal connection was made, the box can lie below or above
the line or both (in the case of completion of two boxes). Then we
need to run a check to see if the other three sides are connected. For
instance: If i and j dots connection needs an evaluation whether it
forms a fourth side of a box, we need to check if the following
position dots are connected: i and (i - columns)  j and (j - columns)
(i - columns) and (j - columns) If the above connections exist then we
can conclude that a box is completed above the   horizontal line drawn
Similar calculations can be performed while checking for boxes below a
horizontal line and in the sides of a vertical line

This game is played by the players in turns. The host is always given
the first turn. If no box is completed on the player’s recent action,
no extra turn would be provided and the player has to wait till their
turn. To achieve this functionality, we maintain the current player
index and increment it on every move. We reset player index to be
first player once the incremental index equals total number of
players.

When a player completes the fourth side of the box, their individual
score increments by a point and an extra turn is awarded. This rule is
implemented by comparing the old score from the game_config map object
to the new updated score. If there is a difference it suggests that
the player has completed the fourth side of one or two boxes and an
extra turn needs to be awarded.

The game finishes when all the dots in the grid are connected. To
check if the game is complete and to update the game state we compute
the sum of all the individual scores of the players and this would be
equal to the total number of boxes since every box completion is worth
one point. This computation would derive us total number boxes
completed. We then find the maximum number of boxes possible by
computing the product of (rows - 1) * (columns - 1). If the values
from both computations are equal we declare the game has ended and
display the final scorecard to the players. All these rules are
implemented on the server side of the application.

 
Challenges and Solutions

Designing the game state needed to be given a good thought to avoid
unnecessary or redundant information to be stored. This also helps in
minimizing unnecessary re-rendering of component when the state object
changes. We made sure we don’t store unnecessary properties in the
game state and try deriving needed values from the information we
already have.

For good user experience we wanted to let the players draw a line to
join the unconnected dots. There were challenges while trying to
achieve this functionality. The lines were not properly rendered, and
it didn’t produce a smooth-fine look. Finally, we tried to achieve
this functionality using React-Konva and we did get good results out
of it.

Another challenge we faced was to notify existing players about new
incoming player in order to make the game available for every player
at the same time. For this we put up a wait screen until all the
required number of players join the game. Upon all the required
players join the game, we enable the start game button for the host to
begin the game and the new game is broadcast to all the players.

Coming up with boxes logic was little tricky. We wanted to avoid
complex logic for checking if a box was formed. We had thoughts of
storing all coordinates possible for drawing squares and validate the
formation of the square. But later we came up with a solution of using
Dot IDs for validating the formation of the square. And this made it
easier for the score calculation as well because the same logic could
be reused.
