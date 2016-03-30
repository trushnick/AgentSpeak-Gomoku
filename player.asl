// Agent player in project course_paper.mas2j

/* Initial beliefs and rules */

bestDecision(0,0,0).

noMovesLeft :- .count(decision(_,_,0), N) & rows(Rows) & columns(Columns) & N = Rows * Columns.
allDecisionsGathered :- .count(decision(_,_,_), N) & rows(Rows) & columns(Columns) & N = Rows * Columns.

/* Initial goals */

/* Plans */

@ltgb1
+letTheGameBegin[source(A)]
	: goingFirst 
	<- 	?rows(R);
		?columns(C);
		-+bestDecision(math.ceil(R / 2), math.ceil(C / 2), 0);
		-letTheGameBegin[source(A)];
		-goingFirst[source(A)];
		+notWinningMove.
@ltgb2
+letTheGameBegin[source(A)] 
	: true 
	<- 	-letTheGameBegin[source(A)].

@d1
+decision(_,_,_) 
	: noMovesLeft 
	<-	.print("All cells are busy, it's a tie!").
@d2
+decision(_,_,_) 
	: allDecisionsGathered 
	<-	.findall(Weight, decision(_, _, Weight), DecisionList);
		!chooseBestDecision(DecisionList).

@cbd1
+!chooseBestDecision([]) 
	: true 
	<-	?bestDecision(X, Y, _);
		.concat("cell", X, Temp);
		.concat(Temp, "_", Temp2);
		.concat(Temp2, Y, Cell);
		.send(Cell, achieve, winningDecision).
		
@cbd2
+!chooseBestDecision([H|T]) 
	: bestDecision(_,_,Weight) & H > Weight 
	<-	?decision(X, Y, H);
		-+bestDecision(X, Y, H);
		!chooseBestDecision(T).
@cbd3		
+!chooseBestDecision([_|T]) 
	: true 
	<- 	!chooseBestDecision(T).

@nwm
+notWinningMove 
	: true 
	<-	?bestDecision(X, Y, _);
		.print("Making move to cell (", X, ",", Y, ")");
		.concat("cell", X, "_", Y, Cell);
		.my_name(Name);
		.send(Cell, tell, busy(Name));
		.abolish(decision(_,_,_));
		-+bestDecision(0,0,0);
		move(X, Y);
		.broadcast(tell, decisionMade).

		
@wm		
+winningMove
	: true
	<- 	?bestDecision(X, Y, _);
		.print("Making move to cell (", X, ",", Y, ")");
		.print("I won");
		.concat("cell", X, "_", Y, Cell);
		.my_name(Name);
		.send(Cell, tell, busy(Name));
		move(X, Y).

/*+winningDecision(X, Y) 
	: true
	<- 	.print("Making move to cell (", X, ",", Y, ")");
		.print("I won!");
		move(X, Y).
		
+decision(0, 0)
	: true
	<- .print("All cells busy, its a tie").

+decision(X, Y)
	: true
	<- 	.print("Making move to cell (", X, ",", Y, ")");
		-decision(X, Y);
		move(X, Y);
		.broadcast(tell, decisionMade).
*/	

@dm
+decisionMade[source(A)] 
	: true 
	<- 	-decisionMade[source(A)];
		//makeDecision.
		.broadcast(achieve, askForDecision).
	
+!askForDecision.
