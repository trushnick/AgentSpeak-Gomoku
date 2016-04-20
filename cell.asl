// Agent cell in project course_paper.mas2j
/* Initial beliefs and rules */

surroundingCells([]).

threat_hl(player1, 0).
threat_hr(player1, 0).
threat_vu(player1, 0).
threat_vd(player1, 0).
threat_db(player1, 0).
threat_df(player1, 0).
threat_sb(player1, 0).
threat_sf(player1, 0).

threat_hl(player2, 0).
threat_hr(player2, 0).
threat_vu(player2, 0).
threat_vd(player2, 0).
threat_db(player2, 0).
threat_df(player2, 0).
threat_sb(player2, 0).
threat_sf(player2, 0).

threat(player1, 0).
threat(player2, 0).

leftColumn :- position(_, Y) & Y == 1.
rightColumn :- position(_, Y) & columns(C) & Y == C.
topRow :- position(X, _) & X == 1.
bottomRow :- position(X, _) & rows(R) & X == R.

/* Initial goals */

/* Plans */

/*
	Осматриваюсь вокруг и завожу список соседних клеток.
*/
@la1[atomic]
+!lookAround
	:	leftColumn & topRow
	<-	?position(X, Y);
		.concat("cell", X    , "_", Y + 1, Cell1);
		.concat("cell", X + 1, "_", Y    , Cell2);
		.concat("cell", X + 1, "_", Y + 1, Cell3);
		-+surroundingCells([Cell1, Cell2, Cell3]).
@la2[atomic]
+!lookAround
	:	leftColumn & bottomRow
	<-	?position(X, Y);
		.concat("cell", X - 1, "_", Y    , Cell1);
		.concat("cell", X - 1, "_", Y + 1, Cell2);
		.concat("cell", X    , "_", Y + 1, Cell3);
		-+surroundingCells([Cell1, Cell2, Cell3]).
@la3[atomic]
+!lookAround
	:	rightColumn & topRow
	<-	?position(X, Y);
		.concat("cell", X    , "_", Y - 1, Cell1);
		.concat("cell", X + 1, "_", Y - 1, Cell2);
		.concat("cell", X + 1, "_", Y    , Cell3);
		-+surroundingCells([Cell1, Cell2, Cell3]).
@la4[atomic]
+!lookAround
	:	rightColumn & bottomRow
	<-	?position(X, Y);
		.concat("cell", X    , "_", Y - 1, Cell1);
		.concat("cell", X - 1, "_", Y - 1, Cell2);
		.concat("cell", X - 1, "_", Y    , Cell3);
		-+surroundingCells([Cell1, Cell2, Cell3]).	
@la5[atomic]
+!lookAround
	:	leftColumn
	<-	?position(X, Y);
		.concat("cell", X - 1, "_", Y    , Cell1);
		.concat("cell", X - 1, "_", Y + 1, Cell2);
		.concat("cell", X    , "_", Y + 1, Cell3);
		.concat("cell", X + 1, "_", Y    , Cell4);
		.concat("cell", X + 1, "_", Y + 1, Cell5);
		-+surroundingCells([Cell1, Cell2, Cell3, Cell4, Cell5]).
@la6[atomic]
+!lookAround
	:	rightColumn
	<-	?position(X, Y);
		.concat("cell", X - 1, "_", Y - 1, Cell1);
		.concat("cell", X - 1, "_", Y    , Cell2);
		.concat("cell", X    , "_", Y - 1, Cell3);
		.concat("cell", X + 1, "_", Y - 1, Cell4);
		.concat("cell", X + 1, "_", Y    , Cell5);
		-+surroundingCells([Cell1, Cell2, Cell3, Cell4, Cell5]).
@la7[atomic]
+!lookAround
	:	topRow
	<-	?position(X, Y);
		.concat("cell", X    , "_", Y - 1, Cell1);
		.concat("cell", X    , "_", Y + 1, Cell2);
		.concat("cell", X + 1, "_", Y - 1, Cell3);
		.concat("cell", X + 1, "_", Y    , Cell4);
		.concat("cell", X + 1, "_", Y + 1, Cell5);
		-+surroundingCells([Cell1, Cell2, Cell3, Cell4, Cell5]).
@la8[atomic]
+!lookAround
	:	bottomRow
	<-	?position(X, Y);
		.concat("cell", X - 1, "_", Y - 1, Cell1);
		.concat("cell", X - 1, "_", Y    , Cell2);
		.concat("cell", X - 1, "_", Y + 1, Cell3);
		.concat("cell", X    , "_", Y - 1, Cell4);
		.concat("cell", X    , "_", Y + 1, Cell5);
		-+surroundingCells([Cell1, Cell2, Cell3, Cell4, Cell5]).
@la9[atomic]
+!lookAround
	:	true
	<-	?position(X, Y);
		.concat("cell", X - 1, "_", Y - 1, Cell1);
		.concat("cell", X - 1, "_", Y    , Cell2);
		.concat("cell", X - 1, "_", Y + 1, Cell3);
		.concat("cell", X    , "_", Y - 1, Cell4);
		.concat("cell", X    , "_", Y + 1, Cell5);
		.concat("cell", X + 1, "_", Y - 1, Cell6);
		.concat("cell", X + 1, "_", Y    , Cell7);
		.concat("cell", X + 1, "_", Y + 1, Cell8);
		-+surroundingCells([Cell1, Cell2, Cell3, Cell4, Cell5, Cell6, Cell7, Cell8]).

/*
	Когда игрок ходит сюда, 
	я обнуляю все угрозы (чтобы в эту клетку больше никто не поставил)
	и распространяю волну для обновления угроз соседних клеток
*/		
@b[atomic]
+busy(Player)
	: 	true
	<- 	?threat(Player, Threat);
		.print("Threat was ", Threat); // For Debug
		-threat_hl(player1, _);
		-threat_hr(player1, _);
		-threat_vu(player1, _);
		-threat_vd(player1, _);
		-threat_db(player1, _);
		-threat_df(player1, _);
		-threat_sb(player1, _);
		-threat_sf(player1, _);
		+threat_hl(player1, -1);
		+threat_hr(player1, -1);
		+threat_vu(player1, -1);
		+threat_vd(player1, -1);
		+threat_db(player1, -1);
		+threat_df(player1, -1);
		+threat_sb(player1, -1);
		+threat_sf(player1, -1);
		-threat_hl(player2, _);
		-threat_hr(player2, _);
		-threat_vu(player2, _);
		-threat_vd(player2, _);
		-threat_db(player2, _);
		-threat_df(player2, _);
		-threat_sb(player2, _);
		-threat_sf(player2, _);
		+threat_hl(player2, -1);
		+threat_hr(player2, -1);
		+threat_vu(player2, -1);
		+threat_vd(player2, -1);
		+threat_db(player2, -1);
		+threat_df(player2, -1);
		+threat_sb(player2, -1);
		+threat_sf(player2, -1);
		-threat(player1, _);
		-threat(player2, _);
		+threat(player1, -1);
		+threat(player2, -1);
		!startWave(Player).
	
/*
	Стартую волновой процесс, посылая волны всем известным соседним клеткам,
	которые были обнаружены на этапе инициализации.
*/
@sw1[atomic]
+!startWave(Player)
	: 	true
	<- 	?surroundingCells(CellList);
		.my_name(I);
		for ( .member(Cell, CellList) ) {
			.send(Cell, achieve, wave(Player, 1, 4, [I]));
		}.	
	
/*
	Распространяю волну в текущем направлении
	
	При распространении могут возникнуть следующие случаи:
	- "Сила волны" равна 0.
		В данном случае ход игрока уже не значим для текущей клетки и для всех 
		последующих, волновой процесс останавливается.
	- Достигнут край игрового поля. 
		В данном случае одно из полей координат следующей клетки будет либо равно 0, 
		либо будет больше чем число рядов/столбцов соответсвенно. При возникновении
		данной ситуации, прекращаю волновой процесс в заданном направлении.
		Данная проверка осуществляется в другом плане (sendForward) после формирования
		координат следующей ячейки.
	- Очередная клетка принадлежит тому игроку, для которого рассчитывается угроза.
		В данном случае вместо деления угроза на 2, угроза увеличивается на 1 и 
		волновой процесс в заданном направлении продолжается. 
		TODO:
		При этом также начинается волновой процесс в обратном направлении (для перерасчета угрозы клеток).
	- Очередная клетка принадлежит другому игроку
		В данном случае волновой процесс расчета угрозы для текущего игрока в 
		заданном направлении прекращается и начинается перерасчет угрозы для другого
		игрока в том же направлении. (TODO)
		
*/
@w1	
+!wave(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: 	CellsToGo = 0.	
@w2
+!wave(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: 	not busy(Player) & .my_name(I) & .member(I, SourceList).	
@w3
+!wave(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: 	busy(Player) & .my_name(I) & .member(I, SourceList)
	<-	!sendForward(Player, Threat + 1, CellsToGo - 1, SourceList, PrevCell).
@w4
+!wave(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: 	not busy(_)
	<- 	?position(X, Y);
		.send(PrevCell, askOne, position(PrevX, PrevY), position(PrevX, PrevY));
		.wait(5);
		!calculateThreat(Player, Threat, X - PrevX, Y - PrevY);
		!sendForward(Player, Threat / 2, CellsToGo - 1, SourceList, PrevCell).
@w5
+!wave(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: 	busy(Player)
	<- 	.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.send(PrevCell, achieve, wave(Player, 1, 4, NewSourceList));
		!sendForward(Player, Threat + 1, CellsToGo - 1, NewSourceList, PrevCell).
@w6
+!wave(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: 	busy(AnotherPlayer)
	<- 	.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		!sendForward(AnotherPlayer, 1, 4, NewSourceList, PrevCell).
	
/*
	Пересылаю волну дальше, если не уперся в край игрового поля.
*/
@sf1
+!sendForward(Player, Threat, CellsToGo, SourceList, PrevCell)
	:	true
	<-	?position(X, Y);
		.send(PrevCell, askOne, position(PrevX, PrevY), position(PrevX, PrevY));
		?rows(R);
		?columns(C);
		NextX = X + X - PrevX;
		NextY = Y + Y - PrevY;
		if ( NextX \== 0 & NextX \== R + 1 & NextY \== 0 & NextY \== C + 1 ) {
			.concat("cell", NextX, "_", NextY, NextCell);
			.send(NextCell, achieve, wave(Player, Threat, CellsToGo, SourceList));
		}.
		
/*
	Вычисляю новую угрозу для соответствующего направления.
	Направление вычисляется на основе моих координат и координат предыдущей клетки.
*/
@ct1
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	:	DeltaX == -1 & DeltaY == -1
	<-	-threat_db(Player, _);
		+threat_db(Player, Threat).
@ct2
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	:	DeltaX == -1 & DeltaY == 0
	<-	-threat_vu(Player, _);
		+threat_vu(Player, Threat).
@ct3
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	:	DeltaX == -1 & DeltaY == 1
	<-	-threat_sf(Player, _);
		+threat_sf(Player, Threat).
@ct4
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	:	DeltaX == 0 & DeltaY == -1
	<-	-threat_hl(Player, _);
		+threat_hl(Player, Threat).
@ct5
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	:	DeltaX == 0 & DeltaY == 1
	<-	-threat_hr(Player, _);
		+threat_hr(Player, Threat).
@ct6
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	:	DeltaX == 1 & DeltaY == -1
	<-	-threat_sb(Player, _);
		+threat_sb(Player, Threat).
@ct7
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	:	DeltaX == 1 & DeltaY == 0
	<-	-threat_vd(Player, _);
		+threat_vd(Player, Threat).
@ct8
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	:	DeltaX == 1 & DeltaY == 1
	<-	-threat_df(Player, _);
		+threat_df(Player, Threat).		
@ct9[atomic, breakpoint]
+!calculateThreat(Player, Threat, DeltaX, DeltaY)
	: 	true
	<-	.print("Not implemented, stopping execution in 10 seconds");
		.wait(10000);
		.stopMAS.
		
		
/*
	А это все потому что правила не работают с askOne
*/
@thl1[atomic]
+threat_hl(Player, HL)
	: 	threat_hr(Player, HR) & threat(Player, Threat) & HL + HR > Threat
	<-	-threat(Player, Threat);
		+threat(Player, HL + HR).
@thr1[atomic]
+threat_hr(Player, HR)
	: 	threat_hl(Player, HL) & threat(Player, Threat) & HL + HR > Threat
	<-	-threat(Player, Threat);
		+threat(Player, HL + HR).
@tvu1[atomic]
+threat_vu(Player, VU)
	: 	threat_vd(Player, VD) & threat(Player, Threat) & VU + VD > Threat
	<-	-threat(Player, Threat);
		+threat(Player, VU + VD).
@tvd1[atomic]
+threat_vd(Player, VD)
	: 	threat_vu(Player, VU) & threat(Player, Threat) & VU + VD > Threat
	<-	-threat(Player, Threat);
		+threat(Player, VU + VD).
@tdb1[atomic]
+threat_db(Player, DB)
	: 	threat_df(Player, DF) & threat(Player, Threat) & DB + DF > Threat
	<-	-threat(Player, Threat);
		+threat(Player, DB + DF).
@tdf1[atomic]
+threat_df(Player, DF)
	: 	threat_db(Player, DB) & threat(Player, Threat) & DB + DF > Threat
	<-	-threat(Player, Threat);
		+threat(Player, DB + DF).
@tsb1[atomic]
+threat_sb(Player, SB)
	: 	threat_sf(Player, SF) & threat(Player, Threat) & SB + SF > Threat
	<-	-threat(Player, Threat);
		+threat(Player, SB + SF).
@tsf1[atomic]
+threat_sf(Player, SF)
	: 	threat_sb(Player, SB) & threat(Player, Threat) & SB + SF > Threat
	<-	-threat(Player, Threat);
		+threat(Player, SB + SF).
		
/*		
	Заглушки
*/
+begin[source(A)]
	: 	true 
	<- 	-begin[source(A)].
+opponent(Name)[source(A)]
	: 	true
	<- 	-opponent(Name)[source(A)].
