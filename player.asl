// Agent player in project course_paper.mas2j

/* Initial beliefs and rules */

my_threats([]).
opponent_threats([]).
my_threats_values([]).
opponent_threats_values([]).

my_threat(MV) :- my_threats_values(VL) & .max(VL, MV).
opponent_threat(OMV) :- opponent_threats_values(OVL) & .max(OVL, OMV).

/* Plans */

@b1
+begin[source(A)]
	: going_first
	<- 	.my_name(I);
		.broadcast(tell, opponent(I));
		?rows(R);
		?columns(C);
		-begin[source(A)];
		-going_first[source(A)];
		!make_first_move(math.ceil( R / 2), math.ceil(C / 2)).
@b2
+begin[source(A)] 
	: true 
	<- 	.my_name(I);
		.broadcast(tell, opponent(I));
		-begin[source(A)].

@mfm
+!make_first_move(X, Y)
	: true
	<- 	.concat("cell", X, "_", Y, Cell);
		.print("Moving first.");
		.print("My move is (", X, ",", Y, ")");
		move(X, Y);
		.my_name(Name);
		.send(Cell, tell, busy(Name));
		?opponent(O);
		.send(O, tell, turn).
	
/*
	В начале хода я спрашиваю у клеток их текущую угрозу
	И делаю ход, основываясь на полученных данных
*/
@t[atomic]
+turn[source(A)]
	: true
	<- 	.wait(300);
		?rows(R);
		?columns(C);
		.my_name(I);
		?opponent(O);
		for ( .range(X, 1, R) ) {
			for ( .range(Y, 1, C) ) {
				.concat("cell", X, "_", Y, Cell);
				.send(Cell, askOne, threat(I, T), threat(I, T));
				.send(Cell, askOne, threat(O, OT), threat(O, OT));
				?my_threats(TL);
				.concat(TL, [[Cell, T]], NTL);
				-+my_threats(NTL);
				?my_threats_values(TVL);
				.concat(TVL, [T], NTVL);
				-+my_threats_values(NTVL);
				?opponent_threats(OTL);
				.concat(OTL, [[Cell, OT]], NOTL);
				-+opponent_threats(NOTL);
				?opponent_threats_values(OTVL);
				.concat(OTVL, [OT], NOTVL);
				-+opponent_threats_values(NOTVL);
			};
		};
		-turn[source(A)];
		!make_move.
	
@mm0
+!make_move
	:	my_threats_values(VL) & .max(VL, -1)
	<-	.print("All cells are busy, its a tie.").
/*
	Делаю ход в указанную клетку. Если угроза равна 4 - я победил,
	иначе - передаю ход.
	P.S. Threat = 1 - победа, иначе не победа.
*/
@mm1		
+!make_move(Cell, Threat)
	: true
	<- 	.send(Cell, askOne, position(X, Y), position(X, Y));
		.print("My move is (", X, ",", Y, ")");
		move(X, Y);
		.my_name(I);
		.send(Cell, tell, busy(I));
		-+my_threats([]);
		-+my_threats_values([]);
		-+opponent_threats([]);
		-+opponent_threats_values([]);
		if (Threat >= 4) {
			.print("I won!");
		} else {
			.wait(1000);
			?opponent(Player);
			.send(Player, tell, turn);
		}.	
/*
	Если я побеждаю на этом ходу, делаю победный ход
	P.S. надо проверять как-то дополнительно, этот ход не обязательно будет
	победным.
*/
@mm2		
+!make_move
	: my_threat(Threat) & Threat == 4
	<- 	?my_threats(TL);
		.member([Cell, Threat], TL);
		!make_move(Cell, Threat).
/*
	Если противник имеет бОльшую угрозу, чем я, - защищаюсь.
	При этом из всех клеток с наибольшей угрозой, выбираю наиболее выгодную для себя (нет)
*/
@mm3
+!make_move
	: my_threat(Threat) & opponent_threat(O_Threat) & O_Threat > Threat
	<-	?opponent_threats(TL);
		.member([Cell, O_Threat], TL);
		/*+decision("cell0_0", -1);
		for ( .member([Cell, O_Threat], TL) ) {
			.member([Cell, Temp_Threat], MTL);
			?decision(TCell, T);
			if (Temp_Threat > T) {
				-+decision(Cell, Temp_Threat);
			};
		};
		?decision(Cell, T);
		-decision(Cell, T);*/
		?my_threats(MTL);
		.member([Cell, My_Threat], MTL);
		!make_move(Cell, My_Threat).
/*
	В любой другой ситуации делаю самый перспективный 
	атакующий ход
*/
@mm4
+!make_move
	: true
	<-	?my_threats_values(VL);
		.max(VL, MV);
		?my_threats(TL);
		.member([Cell, MV], TL);
		!make_move(Cell, MV).
		
/*
	Заглушки
*/
