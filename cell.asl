// Agent cell in project course_paper.mas2j
/* Initial beliefs and rules */

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

// Для отладки
horWin(Player) :- threat_hl(Player, HL) & threat_hr(Player, HR) & HL + HR >= 4.
vertWin(Player) :- threat_vu(Player, VU) & threat_vd(Player, VD) & VU + VD >= 4.
diagWin(Player) :- threat_hl(Player, HL) & threat_hr(Player, HR) & HL + HR >= 4.
sideWin(Player) :- threat_hl(Player, HL) & threat_hr(Player, HR) & HL + HR >= 4.

/* Initial goals */

/* Plans */
// Для отладки
+!doesPlayerWon(Player)
	: 	horWin(Player)
	<-	.print("Horizontal win").
+!doesPlayerWon(Player)
	:	vertWin(Player)
	<-	.print("Vertical win").
+!doesPlayerWon(Player)
	:	diagWin(Player)
	<-	.print("Diagonal win").
+!doesPlayerWon(Player)
	:	sideWin(Player)
	<-	.print("Side diagonal win").
+!doesPlayerWon(Player)
	: 	true.
/*
	Когда игрок ходит сюда, 
	я обнуляю все угрозы (чтобы в эту клетку больше никто не поставил)
	и распространяю волну для обновления угроз соседних клеток
*/
@b[atomic]
+busy(Player)
	: true
	<- 	!doesPlayerWon(Player);
		-+threat_hl(player1, -1);
		-+threat_hr(player2, -1);
		-+threat_vu(player1, -1);
		-+threat_vd(player2, -1);
		-+threat_db(player1, -1);
		-+threat_df(player2, -1);
		-+threat_sb(player1, -1);
		-+threat_sf(player2, -1);
		-threat(player1, _);
		-threat(player2, _);
		+threat(player1, -1);
		+threat(player2, -1);
		!startWave(Player).
	
/*
	Стартую волновой процесс
	При этом надо предусмотреть крайние ситуации:
	- я в одном из углом
	- я в одном из крайних рядов
*/
@sw1[atomic]
+!startWave(Player)
	: leftColumn & topRow
	<- 	?position(X, Y);
		.my_name(I);
		.concat("cell", X, "_", Y + 1, Cell1);
		.concat("cell", X + 1, "_", Y + 1, Cell2);
		.concat("cell", X + 1, "_", Y, Cell3);
		.send(Cell1, achieve, waveHR(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveDF(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveVD(Player, 1, 4, [I])).
@sw2[atomic]		
+!startWave(Player)
	: leftColumn & bottomRow
	<- 	?position(X, Y);
		.my_name(I);
		.concat("cell", X - 1, "_", Y, Cell1);
		.concat("cell", X - 1, "_", Y + 1, Cell2);
		.concat("cell", X, "_", Y + 1, Cell3);
		.send(Cell1, achieve, waveVU(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveSF(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveHR(Player, 1, 4, [I])).
@sw3[atomic]		
+!startWave(Player)
	: rightColumn & bottomRow
	<- 	?position(X, Y);
		.my_name(I);
		.concat("cell", X - 1, "_", Y, Cell1);
		.concat("cell", X - 1, "_", Y - 1, Cell2);
		.concat("cell", X, "_", Y - 1, Cell3);
		.send(Cell1, achieve, waveVU(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveDB(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveHL(Player, 1, 4, [I])).		
@sw4[atomic]
+!startWave(Player)
	: rightColumn & topRow
	<- 	?position(X, Y);
		.my_name(I);
		.concat("cell", X, "_", Y - 1, Cell1);
		.concat("cell", X + 1, "_", Y - 1, Cell2);
		.concat("cell", X + 1, "_", Y, Cell3);
		.send(Cell1, achieve, waveHL(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveSB(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveVD(Player, 1, 4, [I])).		
@sw5[atomic]
+!startWave(Player)
	: leftColumn
	<- 	?position(X, Y);
		.my_name(I);
		.concat("cell", X - 1, "_", Y, Cell1);
		.concat("cell", X - 1, "_", Y + 1, Cell2);
		.concat("cell", X, "_", Y + 1, Cell3);
		.concat("cell", X + 1, "_", Y, Cell4);
		.concat("cell", X + 1, "_", Y + 1, Cell5);
		.send(Cell1, achieve, waveVU(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveSF(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveHR(Player, 1, 4, [I]));
		.send(Cell4, achieve, waveVD(Player, 1, 4, [I]));
		.send(Cell5, achieve, waveDF(Player, 1, 4, [I])).

@sw6[atomic]		
+!startWave(Player)
	: rightColumn 
	<- 	?position(X, Y);
		.my_name(I);
		.concat("cell", X - 1, "_", Y, Cell1);
		.concat("cell", X - 1, "_", Y - 1, Cell2);
		.concat("cell", X, "_", Y - 1, Cell3);
		.concat("cell", X + 1, "_", Y, Cell4);
		.concat("cell", X + 1, "_", Y - 1, Cell5);
		.send(Cell1, achieve, waveVU(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveDB(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveHL(Player, 1, 4, [I]));
		.send(Cell4, achieve, waveVD(Player, 1, 4, [I]));
		.send(Cell5, achieve, waveSB(Player, 1, 4, [I])).
@sw7[atomic]
+!startWave(Player)
	: topRow 
	<- 	?position(X, Y);
		.my_name(I);
		.concat("cell", X, "_", Y - 1, Cell1);
		.concat("cell", X, "_", Y + 1, Cell2);
		.concat("cell", X + 1, "_", Y - 1, Cell3);
		.concat("cell", X + 1, "_", Y, Cell4);
		.concat("cell", X + 1, "_", Y + 1, Cell5);
		.send(Cell1, achieve, waveHL(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveHR(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveSB(Player, 1, 4, [I]));
		.send(Cell4, achieve, waveVD(Player, 1, 4, [I]));
		.send(Cell5, achieve, waveDF(Player, 1, 4, [I])).
@sw8[atomic]
+!startWave(Player)
	: bottomRow 
	<- 	?position(X, Y);
		.my_name(I);
		.concat("cell", X - 1, "_", Y - 1, Cell1);
		.concat("cell", X - 1, "_", Y, Cell2);
		.concat("cell", X - 1, "_", Y + 1, Cell3);
		.concat("cell", X, "_", Y - 1, Cell4);
		.concat("cell", X, "_", Y + 1, Cell5);
		.send(Cell1, achieve, waveDB(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveVU(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveSF(Player, 1, 4, [I]));
		.send(Cell4, achieve, waveHL(Player, 1, 4, [I]));
		.send(Cell5, achieve, waveHR(Player, 1, 4, [I])).
@sw9[atomic]
+!startWave(Player)
	: true
	<-	?position(X, Y);
		.my_name(I);
		.concat("cell", X - 1, "_", Y - 1, Cell1);
		.concat("cell", X - 1, "_", Y, Cell2);
		.concat("cell", X - 1, "_", Y + 1, Cell3);
		.concat("cell", X, "_", Y - 1, Cell4);
		.concat("cell", X, "_", Y + 1, Cell5);
		.concat("cell", X + 1, "_", Y - 1, Cell6);
		.concat("cell", X + 1, "_", Y, Cell7);
		.concat("cell", X + 1, "_", Y + 1, Cell8);
		.send(Cell1, achieve, waveDB(Player, 1, 4, [I]));
		.send(Cell2, achieve, waveVU(Player, 1, 4, [I]));
		.send(Cell3, achieve, waveSF(Player, 1, 4, [I]));
		.send(Cell4, achieve, waveHL(Player, 1, 4, [I]));
		.send(Cell5, achieve, waveHR(Player, 1, 4, [I]));
		.send(Cell6, achieve, waveSB(Player, 1, 4, [I]));
		.send(Cell7, achieve, waveVD(Player, 1, 4, [I]));
		.send(Cell8, achieve, waveDF(Player, 1, 4, [I])).
	
/*
	waveHL - wave horizontal left
	Распространяю волну по горизонтали налево
	Останавливаюсь, когда кол-во оставшихся клеток равно 0 или
	когда упрусь в границу поля. 
	Если нахожу клетку, уже занятую этим игроком, увеличиваю угрозу и передаю дальше и 
	(по идеи) должен отправить в обратном направлении волну, чтобы пересчитать угрозу справа
	Если нахожу клетку, занятую другим игроком, останавливаю волновой процесс и (должен)
	начинаю его в обратном направлении для перерасчета. При этом в текущем направлении надо
	начать распространение для другого игрока (для пересчета угрозы).
	
	Распространение волны в других направлениях абсолютно аналогично этому.
*/
@whl1[atomic]		
+!waveHL(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: CellsToGo = 0.
@whl2[atomic]
+!waveHL(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: leftColumn.	
@whl3[atomic]	
+!waveHL(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: .my_name(I) & .member(I, SourceList) 
	<- 	?position(X, Y);
		.concat("cell", X, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveHL(Player, Threat + 1, CellsToGo - 1, SourceList)).
@whl4[atomic]	
+!waveHL(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: not busy(_)
	<- 	?position(X, Y);
		-threat_hl(Player, _);
		+threat_hl(Player, Threat);
		.concat("cell", X, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveHL(Player, Threat / 2, CellsToGo - 1, SourceList)).
@whl5[atomic]
+!waveHL(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(Player)
	<- 	?position(X, Y);
		.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.concat("cell", X, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveHL(Player, Threat + 1, CellsToGo - 1, NewSourceList));
		.send(PrevCell, achieve, waveHR(Player, 1, 4, NewSourceList)).
// Тут должно быть распространение волны в обратном направлении
@whl6[atomic]
+!waveHL(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(AnotherPlayer).
	
/*
	waveHR - wave horizontal right
	Распространяю волну по горизонтали направо
*/
@whr1[atomic]		
+!waveHR(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: CellsToGo = 0.
@whr2[atomic]
+!waveHR(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: rightColumn.
@whr3[atomic]
+!waveHR(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: .my_name(I) & .member(I, SourceList)
	<- 	?position(X, Y);
		.concat("cell", X, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveHR(Player, Threat + 1, CellsToGo - 1, SourceList)).
@whr4[atomic]	
+!waveHR(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: not busy(_)
	<- 	?position(X, Y);
		-threat_hr(Player, _);
		+threat_hr(Player, Threat);
		.concat("cell", X, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveHR(Player, Threat / 2, CellsToGo - 1, SourceList)).
@whr5[atomic]
+!waveHR(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(Player)
	<- 	?position(X, Y);
		.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.concat("cell", X, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveHR(Player, Threat + 1, CellsToGo - 1, NewSourceList));
		.send(PrevCell, achieve, waveHL(Player, 1, 4, NewSourceList)).
// Тут должно быть распространение волны в обратном направлении
@whr6[atomic]
+!waveHR(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(AnotherPlayer).
	
/*
	waveVU - wave vertical up
	Распространяю волну по вертикали наверх
*/
@wvu1[atomic]		
+!waveVU(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: CellsToGo = 0.
@wvu2[atomic]
+!waveVU(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: topRow.	
@wvu3[atomic]	
+!waveVU(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: .my_name(I) & .member(I, SourceList) 
	<- 	?position(X, Y);
		.concat("cell", X - 1, "_", Y, NextCell);
		.send(NextCell, achieve, waveVU(Player, Threat + 1, CellsToGo - 1, SourceList)).
@wvu4[atomic]	
+!waveVU(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: not busy(_)
	<- 	?position(X, Y);
		-threat_vu(Player, _);
		+threat_vu(Player, Threat);
		.concat("cell", X - 1, "_", Y, NextCell);
		.send(NextCell, achieve, waveVU(Player, Threat / 2, CellsToGo - 1, SourceList)).
@wvu5[atomic]
+!waveVU(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(Player)
	<- 	?position(X, Y);
		.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.concat("cell", X - 1, "_", Y, NextCell);
		.send(NextCell, achieve, waveVU(Player, Threat + 1, CellsToGo - 1, NewSourceList));
		.send(PrevCell, achieve, waveVD(Player, 1, 4, NewSourceList)).
// Тут должно быть распространение волны в обратном направлении
@wvu6[atomic]
+!waveVU(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(AnotherPlayer).

/*
	waveVD - wave vertical down
	Распространяю волну по вертикали вниз
*/
@wvd1[atomic]		
+!waveVD(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: CellsToGo = 0.
@wvd2[atomic]
+!waveVD(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: bottomRow.
@wvd3[atomic]
+!waveVD(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: .my_name(I) & .member(I, SourceList)
	<- 	?position(X, Y);
		.concat("cell", X + 1, "_", Y, NextCell);
		.send(NextCell, achieve, waveVD(Player, Threat + 1, CellsToGo - 1, SourceList)).
@wvd4[atomic]	
+!waveVD(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: not busy(_)
	<- 	?position(X, Y);
		-threat_vd(Player, _);
		+threat_vd(Player, Threat);
		.concat("cell", X + 1, "_", Y, NextCell);
		.send(NextCell, achieve, waveVD(Player, Threat / 2, CellsToGo - 1, SourceList)).
@wvd5[atomic]
+!waveVD(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(Player)
	<- 	?position(X, Y);
		.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.concat("cell", X + 1, "_", Y, NextCell);
		.send(NextCell, achieve, waveVD(Player, Threat + 1, CellsToGo - 1, NewSourceList));
		.send(PrevCell, achieve, waveVU(Player, 1, 4, NewSourceList)).
// Тут должно быть распространение волны в обратном направлении
@wvd6[atomic]
+!waveVD(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(AnotherPlayer).

/*
	waveDB - wave diagonal back
	Распространяю волну по диагонали назад
*/
@wdb1[atomic]		
+!waveDB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: CellsToGo = 0.
@wdb2[atomic]
+!waveDB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: leftColumn | topRow.	
@wdb3[atomic]	
+!waveDB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: .my_name(I) & .member(I, SourceList) 
	<- 	?position(X, Y);
		.concat("cell", X - 1, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveDB(Player, Threat + 1, CellsToGo - 1, SourceList)).
@wdb4[atomic]	
+!waveDB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: not busy(_)
	<- 	?position(X, Y);
		-threat_db(Player, _);
		+threat_db(Player, Threat);
		.concat("cell", X - 1, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveDB(Player, Threat / 2, CellsToGo - 1, SourceList)).
@wdb5[atomic]
+!waveDB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(Player)
	<- 	?position(X, Y);
		.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.concat("cell", X - 1, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveDB(Player, Threat + 1, CellsToGo - 1, NewSourceList));
		.send(PrevCell, achieve, waveDF(Player, 1, 4, NewSourceList)).
// Тут должно быть распространение волны в обратном направлении
@wdb6[atomic]
+!waveDB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(AnotherPlayer).

/*
	waveDF - wave diagonal forward
	Распространяю волну по диагонали вперед
*/
@wdf1[atomic]		
+!waveDF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: CellsToGo = 0.
@wdf2[atomic]
+!waveDF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: rightColumn | bottomRow.
@wdf3[atomic]
+!waveDF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: .my_name(I) & .member(I, SourceList)
	<- 	?position(X, Y);
		.concat("cell", X + 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveDF(Player, Threat + 1, CellsToGo - 1, SourceList)).
@wdf4[atomic]	
+!waveDF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: not busy(_)
	<- 	?position(X, Y);
		-threat_df(Player, _);
		+threat_df(Player, Threat);
		.concat("cell", X + 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveDF(Player, Threat / 2, CellsToGo - 1, SourceList)).
@wdf5[atomic]
+!waveDF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(Player)
	<- 	?position(X, Y);
		.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.concat("cell", X + 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveDF(Player, Threat + 1, CellsToGo - 1, NewSourceList));
		.send(PrevCell, achieve, waveDB(Player, 1, 4, NewSourceList)).
// Тут должно быть распространение волны в обратном направлении
@wdf6[atomic]
+!waveDF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(AnotherPlayer).	
	
/*
	waveSB - wave side [diagonal] back
	Распространяю волну по побочной диагонали назад
*/
@wsb1[atomic]		
+!waveSB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: CellsToGo = 0.
@wsb2[atomic]
+!waveSB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: leftColumn | bottomRow.	
@wsb3[atomic]	
+!waveSB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: .my_name(I) & .member(I, SourceList) 
	<- 	?position(X, Y);
		.concat("cell", X + 1, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveSB(Player, Threat + 1, CellsToGo - 1, SourceList)).
@wsb4[atomic]	
+!waveSB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: not busy(_)
	<- 	?position(X, Y);
		-threat_sb(Player, _);
		+threat_sb(Player, Threat);
		.concat("cell", X + 1, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveSB(Player, Threat / 2, CellsToGo - 1, SourceList)).
@wsb5[atomic]
+!waveSB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(Player)
	<- 	?position(X, Y);
		.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.concat("cell", X + 1, "_", Y - 1, NextCell);
		.send(NextCell, achieve, waveSB(Player, Threat + 1, CellsToGo - 1, NewSourceList));
		.send(PrevCell, achieve, waveSF(Player, 1, 4, NewSourceList)).
// Тут должно быть распространение волны в обратном направлении
@wsb6[atomic]
+!waveSB(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(AnotherPlayer).
	
/*
	waveSF - wave side [diagonal] forward
	Распространяю волну по побочной диагонали вперед
*/
@wsf1[atomic]		
+!waveSF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: CellsToGo = 0.
@wsf2[atomic]
+!waveSF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: rightColumn | topRow.
@wsf3[atomic]
+!waveSF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: .my_name(I) & .member(I, SourceList)
	<- 	?position(X, Y);
		.concat("cell", X - 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveSF(Player, Threat + 1, CellsToGo - 1, SourceList)).
@wsf4[atomic]	
+!waveSF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: not busy(_)
	<- 	?position(X, Y);
		-threat_sf(Player, _);
		+threat_sf(Player, Threat);
		.concat("cell", X - 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveSF(Player, Threat / 2, CellsToGo - 1, SourceList)).
@wsf5[atomic]
+!waveSF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(Player)
	<- 	?position(X, Y);
		.my_name(I);
		.concat(SourceList, [I], NewSourceList);
		.concat("cell", X - 1, "_", Y + 1, NextCell);
		.send(NextCell, achieve, waveSF(Player, Threat + 1, CellsToGo - 1, NewSourceList));
		.send(PrevCell, achieve, waveSB(Player, 1, 4, NewSourceList)).
// Тут должно быть распространение волны в обратном направлении
@wsf6[atomic]
+!waveSF(Player, Threat, CellsToGo, SourceList)[source(PrevCell)]
	: busy(AnotherPlayer).	
	
/*
	А это все потому что правила не работают с askOne
*/
@fsdw1[atomic]
+threat_hl(Player, HL)
	: threat_hr(Player, HR) & threat(Player, Threat) & HL + HR > Threat
	<-	-threat(Player, Threat);
		+threat(Player, HL + HR).
@fsdw2[atomic]
+threat_hr(Player, HR)
	: threat_hl(Player, HL) & threat(Player, Threat) & HL + HR > Threat
	<-	-threat(Player, Threat);
		+threat(Player, HL + HR).
@fsdw3[atomic]
+threat_vu(Player, VU)
	: threat_vd(Player, VD) & threat(Player, Threat) & VU + VD > Threat
	<-	-threat(Player, Threat);
		+threat(Player, VU + VD).
@fsdw4[atomic]
+threat_vd(Player, VD)
	: threat_vu(Player, VU) & threat(Player, Threat) & VU + VD > Threat
	<-	-threat(Player, Threat);
		+threat(Player, VU + VD).
@fsdw5[atomic]
+threat_db(Player, DB)
	: threat_df(Player, DF) & threat(Player, Threat) & DB + DF > Threat
	<-	-threat(Player, Threat);
		+threat(Player, DB + DF).
@fsdw6[atomic]
+threat_df(Player, DF)
	: threat_db(Player, DB) & threat(Player, Threat) & DB + DF > Threat
	<-	-threat(Player, Threat);
		+threat(Player, DB + DF).
@fsdw7[atomic]
+threat_sb(Player, SB)
	: threat_sf(Player, SF) & threat(Player, Threat) & SB + SF > Threat
	<-	-threat(Player, Threat);
		+threat(Player, SB + SF).
@fsdw8[atomic]
+threat_sf(Player, SF)
	: threat_sb(Player, SB) & threat(Player, Threat) & SB + SF > Threat
	<-	-threat(Player, Threat);
		+threat(Player, SB + SF).
		
/*		
	Заглушки
*/
+begin[source(A)]
	: true 
	<- 	-begin[source(A)].
+opponent(Name)[source(A)]
	: true
	<- 	-opponent(Name)[source(A)].
