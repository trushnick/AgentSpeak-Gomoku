// Agent cell in project course_paper.mas2j

/* Initial beliefs and rules */

horizontal(player1, 0, 0).
horizontal(player2, 0, 0).

vertical(player1, 0, 0).
vertical(player2, 0, 0).

diagonal(player1, 0, 0).
diagonal(player2, 0, 0).

sideDiagonal(player1, 0, 0).
sideDiagonal(player2, 0, 0).

startedH :- startedHP | startedHN.
startedV :- startedVP | startedVN.
startedD :- startedDP | startedDN.
startedSD :- startedSDP | startedSDN.
leftColumn :- position(_, Y) & Y == 1.
rightColumn :- position(_, Y) & columns(C) & Y == C.
topRow :- position(X, _) & X == 1.
bottomRow :- position(X, _) & rows(R) & X == R.
/*
	Не уверен в правильности следующих двух правил, 
	сделал их через уравнение прямой, примерно подставив туда ограничение сетки
	и условие победы. Если неправильные, выявится при прогонах 
*/
badDiag :- position(X, Y) & rows(R) & columns(C) & win(W) & 
		   (Y < X - R + W | Y > X + C - W).
badSideDiag :- position(X, Y) & rows(R) & columns(C) & win(W) &
			   (Y < W - X | Y > (R + C - W) - X).
playerWon(A) :- win(W) &
				(horizontal(A, HP, HN) & HP + HN + 1 >= W) | 
				(vertical(A, VP, VN) & VP + VN  + 1 >= W) | 
				(diagonal(A, DP, DN) & DP + DN + 1 >= W).

/* Initial goals */

/* Plans */

/*
	Если у меня спросили решение, а я уже занята
	сообщаю о решении с нулевым весом.
*/
@afd1
+!askForDecision[source(A)] 
	: busy(_) 
	<- 	?position(X, Y);
		.send(A, tell, decision(X, Y, 0)).
/*
	Если я не занята, генерирую случайный вес
	и сообщаю этот вес игроку
*/
@afd2
+!askForDecision[source(A)] 
	: not busy(_) 
	<- 	?position(X, Y);
		.send(A, tell, decision(X, Y, math.ceil(math.random(99) + 1))).
						
/*
	Если меня спросили о том, выиграет ли игрок А,
	если походит сюда, проверяю длину последовательностей по
	горизонтали, вертикали и диагонали и отвечаю игроку исходя из этих
	длин
*/
@wd
+!winningDecision[source(A)]
	: true
	<- 	//.send(A, tell, notWinningMove).
		!horSeq(A);
		!vertSeq(A);
		!diagSeq(A);
		!sideDiagSeq(A);
		.wait(1000);
		!doesThePlayerWon(A).

/*
	Если я нахожусь в левом столбце, то чтобы узнать
	последовательность ходов игрока А, 
	надо спросить только у клеток справа (слева клеток нету)
*/
@hs1[atomic]
+!horSeq(A) 
	: leftColumn
	<-	?position(X, Y);
		+startedHN;
		.concat("cell", X, "_", Y + 1, NextCell);
		.send(NextCell, achieve, horSeqN(A)).
/*
	По аналогии с предыдущим случаем, надо спросить только у клеток слева
*/
@hs2[atomic]
+!horSeq(A) 
	: rightColumn
	<-	?position(X, Y);
		+startedHP;
		.concat("cell", X, "_", Y - 1, PrevCell);
		.send(PrevCell, achieve, horSeqP(A)).
/*
	Если я не в левом и не в правом столбце, надо спросить у клеток
	и слева, и справа
*/
@hs3[atomic]
+!horSeq(A) 
	: true
	<-	?position(X, Y);
		+startedHP;
		+startedHN;
		.concat("cell", X, "_", Y - 1, PrevCell);
		.send(PrevCell, achieve, horSeqP(A));
		.concat("cell", X, "_", Y + 1, NextCell);
		.send(NextCell, achieve, horSeqN(A)).
			
/*
	Все по аналогии с горизонтальной последовательностью
*/
@vs1[atomic]
+!vertSeq(A) 
	: topRow
	<-	?position(X, Y);
		+startedVN;
		.concat("cell", X + 1, "_", Y, NextCell);
		.send(NextCell, achieve, vertSeqN(A)).
@vs2[atomic]
+!vertSeq(A) 
	: bottomRow
	<-	?position(X, Y);
		+startedVP;
		.concat("cell", X - 1, "_", Y, PrevCell);
		.send(PrevCell, achieve, vertSeqP(A)).
@vs3[atomic]		
+!vertSeq(A) 
	: true
	<-	?position(X, Y);
		+startedVP;
		+startedVN;
		.concat("cell", X - 1, "_", Y, PrevCell);
		.send(PrevCell, achieve, vertSeqP(A));
		.concat("cell", X + 1, "_", Y, NextCell);
		.send(NextCell, achieve, vertSeqN(A)).		
		
/*
	Опять же, по аналогии с горизонтальной последовательностью
*/
@ds1[atomic]
+!diagSeq(A)
	: badDiag
	<-	.print("Bad diag").
@ds2[atomic]
+!diagSeq(A) 
	: topRow | leftColumn
	<-	?position(X, Y);
		+startedDN;
		.concat("cell", X + 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, diagSeqN(A)).
@ds3[atomic]
+!diagSeq(A)
	: bottomRow | rightColumn
	<- 	?position(X, Y);
		+startedDP;
		.concat("cell", X - 1, "_", Y - 1, PrevCell);
		.send(PrevCell, achieve, diagSeqP(A)).
@ds4[atomic]
+!diagSeq(A) 
	: true
	<-	?position(X, Y);
		+startedDP;
		+startedDN;
		.concat("cell", X - 1, "_", Y -1, PrevCell);
		.send(PrevCell, achieve, diagSeqP(A));
		.concat("cell", X + 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, diagSeqN(A)).
		
/*
	Опять же, по аналогии с горизонтальной последовательностью
*/
@sds1[atomic]
+!sideDiagSeq(A)
	: badSideDiag
	<-	.print("Bad side diag").
@sds2[atomic]
+!sideDiagSeq(A) 
	: bottomRow | leftColumn
	<-	?position(X, Y);
		+startedSDN;
		.concat("cell", X - 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, sideDiagSeqN(A)).
@sds3[atomic]
+!sideDiagSeq(A)
	: topRow | rightColumn
	<- 	?position(X, Y);
		+startedSDP;
		.concat("cell", X + 1, "_", Y - 1, PrevCell);
		.send(PrevCell, achieve, sideDiagSeqP(A)).
@sds4[atomic]
+!sideDiagSeq(A) 
	: true
	<-	?position(X, Y);
		+startedSDP;
		+startedSDN;
		.concat("cell", X + 1, "_", Y - 1, PrevCell);
		.send(PrevCell, achieve, sideDiagSeqP(A));
		.concat("cell", X - 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, sideDiagSeqN(A)).		

/*
	При проверке на победу игрока, если сработало правило playerWon,
	то сообщаем ему, что он победит, сделав ход
*/
@dpw1
+!doesThePlayerWon(A)
	: playerWon(A)
	<- .send(A, tell, winningMove).		
/*
	Если расчет последовательностей еще не закончен,
	ждем одну секунду и повторяем вычисление
*/
@dpw2
+!doesThePlayerWon(A)
	: startedH | startedV | startedD
	<- .at("now +1 s", {+!doesThePlayerWon(A)}).
/*
	Если расчеты закончены и игрок не победил этим ходом,
	сообщаем ему об этом
*/
@dpw3
+!doesThePlayerWon(A) 
	: true
	<- .send(A, tell, notWinningMove).

/*
	Если игрок сюда еще не ходил, его последовательность прерывается,
	возвращаем нулевую последовательность
*/
@hsp1[atomic]
+!horSeqP(A)[source(Cell)]
	: not busy(A)
	<- .send(Cell, tell, hSP(A, 0)).
/*
	Если достигли края доски, возвращаем единичную последовательность
*/
@hsp2[atomic]
+!horSeqP(A)[source(Cell)]
	: leftColumn
	<- .send(Cell, tell, hSP(A, 1)).
/*
	В других случаях передаем запрос далее
*/
@hsp3[atomic]
+!horSeqP(A)[source(_)]
	: true
	<- 	?position(X, Y);
		.concat("cell", X, "_", Y - 1, PrevCell);
		.send(PrevCell, achieve, horSeqP(A)).
		
/*
	Аналогично
*/
@hsn1[atomic]
+!horSeqN(A)[source(Cell)]
	: not busy(A)
	<- .send(Cell, tell, hSN(A, 0)).
@hsn2[atomic]
+!horSeqN(A)[source(Cell)]
	: rightColumn
	<- .send(Cell, tell, hSN(A, 1)).
@hsn3[atomic]
+!horSeqN(A)[source(_)]
	: true
	<- 	?position(X, Y);
		.concat("cell", X, "_", Y + 1, NextCell);
		.send(NextCell, achieve, horSeqN(A)).

/*
	Аналогично
*/
@vsp1[atomic]
+!vertSeqP(A)[source(Cell)]
	: not busy(A)
	<- .send(Cell, tell, vSP(A, 0)).
@vsp2[atomic]
+!vertSeqP(A)[source(Cell)]
	: topRow
	<- .send(Cell, tell, vSP(A, 1)).
@vsp3[atomic]
+!vertSeqP(A)[source(_)]
	: true
	<- 	?position(X, Y);
		.concat("cell", X - 1, "_", Y, PrevCell);
		.send(PrevCell, achieve, vertSeqP(A)).
		
/*
	Аналогично
*/
@vsn1[atomic]
+!vertSeqN(A)[source(Cell)]
	: not busy(A)
	<- .send(Cell, tell, vSN(A, 0)).
@vsn2[atomic]
+!vertSeqN(A)[source(Cell)]
	: bottomRow
	<- .send(Cell, tell, vSN(A, 1)).
@vsn3[atomic]
+!vertSeqN(A)[source(_)]
	: true
	<- 	?position(X, Y);
		.concat("cell", X + 1, "_", Y, NextCell);
		.send(NextCell, achieve, vertSeqN(A)).

/*
	Аналогично
*/
@dsp1[atomic]
+!diagSeqP(A)[source(Cell)]
	: not busy(A)
	<- .send(Cell, tell, dSP(A, 0)).
@dsp2[atomic]
+!diagSeqP(A)[source(Cell)]
	: topRow | leftColumn
	<- .send(Cell, tell, dSP(A, 1)).
@dsp3[atomic]
+!diagSeqP(A)[source(_)]
	: true
	<- 	?position(X, Y);
		.concat("cell", X - 1, "_", Y - 1, PrevCell);
		.send(PrevCell, achieve, diagSeqP(A)).
		
/*
	Аналогично
*/
@dsn1[atomic]
+!diagSeqN(A)[source(Cell)]
	: not busy(A)
	<- .send(Cell, tell, dSN(A, 0)).
@dsn2[atomic]
+!diagSeqN(A)[source(Cell)]
	: bottomRow | rightColumn
	<- .send(Cell, tell, dSN(A, 1)).
@dsn3[atomic]
+!diagSeqN(A)[source(_)]
	: true
	<- 	?position(X, Y);
		.concat("cell", X + 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, diagSeqN(A)).		
		
/*
	Аналогично
*/
@sdsp1[atomic]
+!sideDiagSeqP(A)[source(Cell)]
	: not busy(A)
	<- .send(Cell, tell, sdSP(A, 0)).
@sdsp2[atomic]
+!sideDiagSeqP(A)[source(Cell)]
	: bottomRow | leftColumn
	<- .send(Cell, tell, sdSP(A, 1)).
@sdsp3[atomic]
+!sideDiagSeqP(A)[source(_)]
	: true
	<- 	?position(X, Y);
		.concat("cell", X + 1, "_", Y - 1, PrevCell);
		.send(PrevCell, achieve, sideDiagSeqP(A)).
		
/*
	Аналогично
*/
@sdsn1[atomic]
+!sideDiagSeqN(A)[source(Cell)]
	: not busy(A)
	<- .send(Cell, tell, sdSN(A, 0)).
@sdsn2[atomic]
+!sideDiagSeqN(A)[source(Cell)]
	: topRow | rightColumn
	<- .send(Cell, tell, sdSN(A, 1)).
@sdsn3[atomic]
+!sideDiagSeqN(A)[source(_)]
	: true
	<- 	?position(X, Y);
		.concat("cell", X - 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, sideDiagSeqN(A)).	
		
/*
	Backtrace последовательностей
*/
// Горизонталь
@hspb1[atomic]
+hSP(A, S)[source(C)]
	: startedHP
	<- 	?horizontal(A, PS, NS);
		-startedHP;
		-hSP(A, S)[source(C)];
		-horizontal(A, PS, NS);
		+horizontal(A, S, NS).
@hspb2[atomic]
+hSP(A, S)[source(C)]
	: true
	<- 	?position(X, Y);
		-hSP(A, S)[source(C)];
		.concat("cell", X, "_", Y + 1, Cell);
		.send(Cell, tell, hSP(A, S + 1)).
@hsnb1[atomic]
+hSN(A, S)[source(C)]
	: startedHN
	<- 	?horizontal(A, PS, NS);
		-startedHN;
		-hSN(A, S)[source(C)];
		-horizontal(A, PS, NS);
		+horizontal(A, PS, S).
@hsnb2[atomic]
+hSN(A,S)[source(C)]
	: true
	<- ?position(X, Y);
		-hSN(A, S)[source(C)];
		.concat("cell", X, "_", Y - 1, Cell);
		.send(Cell, tell, hSN(A, S + 1)).
// Вертикаль
@vspb1[atomic]
+vSP(A,S)[source(C)]
	: startedVP
	<- 	?vertical(A, PS, NS);
		-startedVP;
		-vSP(A, S)[source(C)];
		-vertical(A, PS, NS);
		+vertical(A, S, NS).
@vspb2[atomic]
+vSP(A,S)[source(C)]
	: true
	<- 	?position(X, Y);
		-vSP(A, S)[source(C)];
		.concat("cell", X + 1, "_", Y, Cell);
		.send(Cell, tell, vSP(A, S + 1)).
@vsnb1[atomic]
+vSN(A,S)[source(C)]
	: startedVN
	<- 	?vertical(A, PS, NS);
		-startedVN;
		-vSN(A, S)[source(C)];
		-vertical(A, PS, NS);
		+vertical(A, PS, S).
@vsnb2[atomic]
+vSN(A,S)[source(C)]
	: true
	<- ?position(X, Y);
		-vSN(A, S)[source(C)];
		.concat("cell", X - 1, "_", Y, Cell);
		.send(Cell, tell, vSN(A, S + 1)).
// Диагональ
@dspb1[atomic]
+dSP(A,S)[source(C)]
	: startedDP
	<- 	?diagonal(A, PS, NS);
		-startedDP;
		-dSP(A, S)[source(C)];
		-diagonal(A, PS, NS);
		+diagonal(A, S, NS).
@dspb2[atomic]		
+dSP(A,S)[source(C)]
	: true
	<- 	?position(X, Y);
		-dSP(A, S)[source(C)];
		.concat("cell", X + 1, "_", Y + 1, Cell);
		.send(Cell, tell, dSP(A, S + 1)).
@dsnb1[atomic]		
+dSN(A,S)[source(C)]
	: startedDN
	<- 	?diagonal(A, PS, NS);
		-startedDN;
		-dSN(A, S)[source(C)];
		-diagonal(A, PS, NS);
		+diagonal(A, PS, S).
@dsnb2[atomic]		
+dSN(A,S)[source(C)]
	: true
	<- ?position(X, Y);
		-dSN(A, S)[source(C)];
		.concat("cell", X - 1, "_", Y - 1, Cell);
		.send(Cell, tell, dSN(A, S + 1)).		
// Побочная диагональ		
@sdspb1[atomic]
+sdSP(A,S)[source(C)]
	: startedSDP
	<- 	?sideDiagonal(A, PS, NS);
		-startedSDP;
		-sdSP(A, S)[source(C)];
		-sideDiagonal(A, PS, NS);
		+sideDiagonal(A, S, NS).
@sdspb2[atomic]		
+sdSP(A,S)[source(C)]
	: true
	<- 	?position(X, Y);
		-sdSP(A, S)[source(C)];
		.concat("cell", X - 1, "_", Y + 1, Cell);
		.send(Cell, tell, sdSP(A, S + 1)).
@sdsnb1[atomic]		
+sdSN(A,S)[source(C)]
	: startedSDN
	<- 	?sideDiagonal(A, PS, NS);
		-startedSDN;
		-sdSN(A, S)[source(C)];
		-sideDiagonal(A, PS, NS);
		+sideDiagonal(A, PS, S).
@sdsnb2[atomic]		
+sdSN(A,S)[source(C)]
	: true
	<- ?position(X, Y);
		-sdSN(A, S)[source(C)];
		.concat("cell", X + 1, "_", Y - 1, Cell);
		.send(Cell, tell, sdSN(A, S + 1)).	
		
/*
	Заглушки
*/
+letTheGameBegin 
	: true 
	<- 	-letTheGameBegin.
	
+decisionMade[source(A)] 
	: true 
	<- 	-decisionMade[source(A)].
