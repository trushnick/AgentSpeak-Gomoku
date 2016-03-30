// Agent initiator in project course_paper.mas2j

/* Initial beliefs and rules */

rows(15).
columns(15).
win(5).

/* Initial goals */

!initGame.

/* Plans */

+!initGame 
	: true 
	<- 	!initPlayers;
  		!initBoard(1, 1);
		?rows(Rows);
		.broadcast(tell, rows(Rows));
		?columns(Columns);
		.broadcast(tell, columns(Columns));
		?win(W);
		.broadcast(tell, win(W));
		!startGame.

+!initBoard(X,Y) 
	: columns(MaxColumn) & Y <= MaxColumn & rows(MaxRow) & X <= MaxRow 
	<-	.print("Initiating cell (", X, ",", Y, ")");
		.concat("cell", X, "_", Y, Cell);
		.create_agent(Cell, "cell.asl");
		.send(Cell, tell, position(X,Y));
		!initBoard(X, Y + 1).
+!initBoard(X,Y) 
	: columns(MaxColumn) & Y > MaxColumn 
	<- !initBoard(X + 1, 1).			   
+!initBoard(X,Y) 
	: rows(MaxRow) & X > MaxRow 
	<- 	.print("Last row built, board complete.").
				   
+!initPlayers 
	: true 
	<- 	.print("Initiating players");
		.concat("player", 1, FirstPlayer);
		.concat("player", 2, SecondPlayer);
		.create_agent(FirstPlayer, "player.asl");
		.create_agent(SecondPlayer, "player.asl");
		.send(FirstPlayer, tell, goingFirst).
						
+!startGame 
	: true 
	<- 	.print("Players and board initiated, let the game begin!");
		.broadcast(tell, letTheGameBegin).
					  
+!askForDecision.
+decisionMade[source(A)] 
	: true 
	<- 	-decisionMade[source(A)].
