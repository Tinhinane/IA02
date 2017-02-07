% ----------------------------------------------
	% Les tours et le plateau sont gérés dynamiquement.

:- dynamic(tourdujoueur/1).
:- dynamic(plateau/1).

% ----------------------------------------------


% --------------------------------------------------------
% 			----- opérations sur les listes -----
% --------------------------------------------------------

% affiche(L) : affiche les éléments d'une liste en allant à la ligne.
affiche([]).
affiche([X|R]) :-  write(X),nl,affiche(R) .

% affiche2(L) : affiche les éléments d'une liste séparé par une tabulation.
affiche2([]).
affiche2([X|R]) :- write(X),tab(1), affiche2(R).

% affiche3(L,LI) : affiche les éléments de deux liste cote a cote. (LI doit forcement contenir des nombres) (utilisé pr afficher les piles de marchandises avec leurs indices)
affiche3([],[]).
affiche3([X|R],[X2|R2]) :- X3 is X2+1,write(X3),tab(1),write(X),nl,affiche3(R,R2) .

% melangeListe : Change l'ordre des éléments de List et unifie le résultat dans melangeListed (le mélange se fait aléatoirement). 
melangeListe(List, MelangeListed) :-
  length(List, Len),
  melangeListe(Len, List, MelangeListed).
melangeListe(0, [], []) :- !.
melangeListe(Len, List, [Elem|Q]) :-
  random(0,Len,RandInd),
  nth0(RandInd, List, Elem),
  select(Elem, List, Rest),
  !,
  NewLen is Len - 1,
  melangeListe(NewLen, Rest, Q).

% appartient_a(X,L) : vrai si l'élément X appartient à la liste L
appartient_a(X,[X|_]).
appartient_a(X,[_|L]) :- appartient_a(X,L). /*,!*/

% nth0(N,L,E): est vrai si E est le N ieme element de la liste L.

% compte(L,N) est vrai si N est le nombre d'éléments dans la liste L.
compte([],0).
compte([_|R],N) :- compte(R,N1), N is N1+1, N>0 .

% occurrence(L,X,N) est vrai si N est le nombre de fois où X est présent dans la liste L.
occurrence([],_,0).
occurrence([X|L],X,N) :- occurrence(L,X,N1),N is N1+1 .
occurrence([Y|L],X,N) :- X\==Y,occurrence(L,X,N).

% Ajouter l'element X dans L, resultat dans NewL.
ajout_Elem_L(X,L, NewL) :- NewL = [X|L].

% supprimer(X,L1,L2) est vrai lorsque L2 est la liste obtenue par suppression de la premiere occurrence de X dans L1 ()ou lorsque x ne figure pas dans l1 et que l2=l1)
supprimer(_,[],[]).
supprimer(X,[X|L1],L1).
supprimer(X,[Y|L1],L2):- X\==Y , ajout_Elem_L(Y,L3,L2), supprimer(X,L1,L3).

/*Revoir substitue si elle fonctionne correctement et regler le Warning...*/
% substitue(X,Y,L1,L2) est vrai si L2 est le résultat du remplacement de la 1ere occurrence de X par Y dans L1.
substitue(_,_,[],[]).
substitue(X,Y,[X|R],R1) :- ajout_Elem_L(Y,R,R1).
substitue(X,Y,[Z|R],[Z|R1]) :- X\==Z,ajout_Elem_L(Z,R1,L2), substitue(X,Y,R,R1).

% --------------------------------------------------------
% 	----- Creation et affichage d'un plateau -----
% --------------------------------------------------------

% ----- Prédicat défini pour l'initialisation du plateau -----

liste_marchandises(
	[mais, riz, ble, ble, 	ble, mais, sucre, riz, cafe, sucre, cacao, riz,cafe, mais, sucre, mais,
	cacao, mais, ble, sucre, riz, cafe, sucre, ble, cafe, ble, sucre, cacao, mais, cacao, cacao,cafe,riz,riz,cafe,cacao]
).
divise_en_9piles([],[]).
divise_en_9piles([A,B,C,D|Q],L):-divise_en_9piles(Q,L1),ajout_Elem_L([A,B,C,D],L1, L).

% ----- Creation du plateau de depart -----

/* On pourrait mélanger la liste des marchandises pour que la partie soit différente à chaque fois (utiliser la fonction melangeListe)
ATTANTION dans lenonce on veut : plateau_depart(Plateau)*/
plateau_depart(Plateau) :-
	liste_marchandises(Marchandises),
	melangeListe(Marchandises,MarchandisesMelangees),
	divise_en_9piles(MarchandisesMelangees,MarchandisesDepart),
	asserta(tourdujoueur(j1)),
	asserta(plateau([MarchandisesDepart, [[ble,7],[riz,6],[cacao,6],[cafe,6],[sucre,6],[mais,6]], [0], [], []])),
	plateau(Plateau).

% ----- Affichage d'un plateau -----

affichage_marchandises(L):- findall(I,nth0(I,L,_),LI),affiche3(L,LI).

affiche_plateau(Plateau):-
	Plateau = [Marchandises, Bourse, PositionTrader, ReserveJoueur1, ReserveJoueur2],nl,
	write('PositionTrader:'),nl,
	PositionTrader = [X],
	Aff_PosTrader is X+1,
	write(Aff_PosTrader),nl,nl,
	write('Marchandises:'),nl,
	affichage_marchandises(Marchandises),nl,
	write('Bourse:'),nl,
	affiche2(Bourse),nl,nl,
	write('ReserveJoueur1:'),nl,
	affiche2(ReserveJoueur1),nl,
	write('ReserveJoueur2:'),nl,
	affiche2(ReserveJoueur2),nl,nl.
	
aff_jeu_depart :- plateau(X),affiche_plateau(X).


% --------------------------------------------------------
% 				----- Coup Possible -----
% --------------------------------------------------------
/* Actuellement le joueur peut rentrer le coup :  [_,_,_,_] */
% Prédicats utiles pour verifier coup :

joueur([j1,j2]).
deplacement([1,2,3]).
position_autour_Trader(Plateau,Pos1,Pos2):-
	Plateau = [Marchandises,_,PositionTrader,_,_],
	nbpilesMarchandises(Marchandises,N),
	nth0(0,PositionTrader,X),
	Pos1a is X - 1 ,
	Pos1 is mod(Pos1a,N),
	nth0(0,PositionTrader,Y),
	Pos2a is Y + 1 ,
	Pos2 is mod(Pos2a,N).

% joueur_possible(X) est vrai si X=j1 ou X=j2.
joueur_possible(X):- joueur(L_joueur), appartient_a(X,L_joueur),!.

% deplacement_possible(X) est vrai si X compris entre 1 et 3.	
deplacement_possible(X):- deplacement(L_deplacements), appartient_a(X,L_deplacements).
	
ressources_possible(Res1,Res2,Marchandises,Pos1,Pos2):-
	nth0(Pos1,Marchandises,Pile_pos1),
	nth0(0,Pile_pos1,Res1),
	nth0(Pos2,Marchandises,Pile_pos2),
	nth0(0,Pile_pos2,Res2).

ressources_possible(Res1,Res2,Marchandises,Pos1,Pos2):-
	nth0(Pos1,Marchandises,Pile_pos1),
	nth0(0,Pile_pos1,Res2),
	nth0(Pos2,Marchandises,Pile_pos2),
	nth0(0,Pile_pos2,Res1).

% coup_possible(Plateau,Coup) est vrai si en fonction du Plateau, le Coup est possible.

coup_possible(Plateau,Coup):-
	Coup = [Joueur,Deplacement,Res1,Res2],
	Plateau = [Marchandises, Bourse, PositionTrader, ReserveJoueur1, ReserveJoueur2],
	joueur_possible(Joueur),
	deplacement_possible(Deplacement),
	deplacer_Trader(Coup,Marchandises,Marchandises,PositionTrader,NouvellePosition),
	Plateau_apres_dep = [Marchandises, Bourse, NouvellePosition, ReserveJoueur1, ReserveJoueur2],
	position_autour_Trader(Plateau_apres_dep,Pos1,Pos2),
	ressources_possible(Res1,Res2,Marchandises,Pos1,Pos2).
	
% --------------------------------------------------------
% 				----- Joueur coup -----
% --------------------------------------------------------

% ----- Deplacement du Trader -----

nbpilesMarchandises(Marchandises,N):-compte(Marchandises,N).
	
deplacer_Trader(Coup,Marchandises,NewMarchandise,Position,NewPosition):-
	Coup=[_,Deplacement,_,_],
	nbpilesMarchandises(Marchandises,N1),
	nbpilesMarchandises(NewMarchandise,N2),
	NbPilesRetirees is N1-N2,
	nth0(0,Position,X),
	X1 is Deplacement+X,
	X2 is X1-NbPilesRetirees,
	P is mod(X2,N2),
	NewPosition = [P].

% ----- traitement_reserve -----
% Strucute Si ... Alors ... Sinon ... http://pcaboche.developpez.com/article/prolog/programmation-prolog/

traitement_reserve(Coup,R1,R2,NewR1,NewR2):-
	Coup = [Joueur,_,Res,_],
	Joueur == j1, !,
		NewR2 = R2,
		ajout_Elem_L(Res,R1, NewR1).
		
traitement_reserve(Coup,R1,R2,NewR1,NewR2):-
	Coup = [Joueur,_,Res,_],
	Joueur == j2, !,
		NewR1 = R1,
		ajout_Elem_L(Res,R2, NewR2).

% ----- traitement_bourse -----

valMarchandiseEnBourse(Bourse,Ressource,Valeur):-
	appartient_a([Ressource,Valeur],Bourse).

traitement_bourse(Coup,Bourse,NewBourse):-
	Coup = [_,_,_,Res2],
	valMarchandiseEnBourse(Bourse,Res2,Valeur),
	X is Valeur-1,
	substitue([Res2,Valeur],[Res2,X],Bourse,NewBourse).
	
% ----- Traitement marchandises -----

traitement_marchandises(Coup,PositionTrader,Marchandises,NewMarchandise):-
	deplacer_Trader(Coup,Marchandises,Marchandises,PositionTrader,NouvellePosition),
	Plateau_apres_dep = [Marchandises, _, NouvellePosition, _, _],
	position_autour_Trader(Plateau_apres_dep,Pos1,Pos2),
	nth0(Pos1,Marchandises,Pile1),
	nth0(Pos2,Marchandises,Pile2),
	nth0(0,Pile1,Res1),
	nth0(0,Pile2,Res2),
	supprimer(Res1,Pile1,NewPile1),
	supprimer(Res2,Pile2,NewPile2),
	substitue(Pile1,NewPile1,Marchandises,X),
	substitue(Pile2,NewPile2,X,NewMarchandise).
	
retire_pile_vide(Marchandises,NewMarchandise):- /* Pourrait etre mieux faite (supprimer toutes les occurences de [] et non seulement 2...)*/
	delete(Marchandises,[],NewMarchandise).

% ----- Joueur coup (utilise tous les traitements précédents) -----

jouer_coup(PlateauInitial,Coup,NouveauPlateau):-
	coup_possible(PlateauInitial,Coup),
	PlateauInitial = [Marchandises, Bourse, PositionTrader, ReserveJoueur1, ReserveJoueur2],
	traitement_reserve(Coup,ReserveJoueur1,ReserveJoueur2,NewR1,NewR2),
	traitement_bourse(Coup,Bourse,NewBourse),
	traitement_marchandises(Coup,PositionTrader,Marchandises,Mintermediaire),
	retire_pile_vide(Mintermediaire,NewMarchandise),
	deplacer_Trader(Coup,Marchandises,NewMarchandise,PositionTrader,NouvellePosition),
	NouveauPlateau = [NewMarchandise, NewBourse, NouvellePosition, NewR1, NewR2],
	
	tourdujoueur(J),
	J == j1,!,
	retractall(tourdujoueur(_)),asserta(tourdujoueur(j2)).
	
jouer_coup(PlateauInitial,Coup,NouveauPlateau):-
	coup_possible(PlateauInitial,Coup),
	PlateauInitial = [Marchandises, Bourse, PositionTrader, ReserveJoueur1, ReserveJoueur2],
	traitement_reserve(Coup,ReserveJoueur1,ReserveJoueur2,NewR1,NewR2),
	traitement_bourse(Coup,Bourse,NewBourse),
	traitement_marchandises(Coup,PositionTrader,Marchandises,Mintermediaire),
	retire_pile_vide(Mintermediaire,NewMarchandise),
	
	deplacer_Trader(Coup,Marchandises,NewMarchandise,PositionTrader,NouvellePosition),
	NouveauPlateau = [NewMarchandise, NewBourse, NouvellePosition, NewR1, NewR2],
	tourdujoueur(J),
	J == j2,!,
	retractall(tourdujoueur(_)),asserta(tourdujoueur(j1)).
	
% -------------------------------------------------------------
% 			---- Intelligence Artificielle ----
% -------------------------------------------------------------

% ---- Liste des coups possibles ----

% Retourne la liste de tous les coups possibles d'un joueur J suivant le plateau actuel.
coups_possibles(Plateau,ListeCoupsPossibles):-
	tourdujoueur(J),
	Coup = [J,_,_,_],
	findall(Coup,coup_possible(Plateau,Coup),ListeCoupsPossibles),
	affiche(ListeCoupsPossibles). /* Juste ici pour verifications de ce que l'ordi peut choisir */
	
% ---- Meilleur Coups ----

max(X,Y,Y)  :-  X  =<  Y,!.
max(X,_,X).

max_l([X],X) :- !, true.
max_l([X|Xs], M):- max_l(Xs, M), M >= X.
max_l([X|Xs], X):- max_l(Xs, M), X >  M.

score(Plateau,Coup,Score):-
	Plateau=[_,Bourse,_,ReserveJ1,ReserveJ2],
	Coup =[J,_,ResAGarder,ResAJeter],
	J == j1,!,
	ajout_Elem_L(ResAGarder,ReserveJ1, ReserveJ1bis),
	valMarchandiseEnBourse(Bourse,ResAGarder,Valeur),
	occurrence(ReserveJ1bis,ResAJeter,NbResJ1),
	occurrence(ReserveJ2,ResAJeter,NbResJ2),
	ScoreJeter is NbResJ2 - NbResJ1,
	Score is Valeur + ScoreJeter.
	
score(Plateau,Coup,Score):-
	Plateau=[_,Bourse,_,ReserveJ1,ReserveJ2],
	Coup =[J,_,ResAGarder,ResAJeter],
	J == j2,!,
	ajout_Elem_L(ResAGarder,ReserveJ2, ReserveJ2bis),
	valMarchandiseEnBourse(Bourse,ResAGarder,Valeur),
	occurrence(ReserveJ1,ResAJeter,NbResJ1),
	occurrence(ReserveJ2bis,ResAJeter,NbResJ2),
	ScoreJeter is NbResJ1 - NbResJ2,
	Score is Valeur + ScoreJeter.

% scoreList(ListedeCoups,ListeScoreAssociée)
scoreList([],[]).
scoreList([T|Q],[Score|Q1]):-plateau(P),score(P,T,Score),scoreList(Q,Q1).

meilleur_coup(Plateau,Meilleur_coup):-		
	coups_possibles(Plateau,ListeCoupsPossibles),
	scoreList(ListeCoupsPossibles,ListeScore),
	max_l(ListeScore,Max),
	nth0(Indice,ListeScore,Max),
	affiche(ListeScore),
	nth0(Indice,ListeCoupsPossibles,Meilleur_coup).
	
% --------------------------------------------------------
% 			----- Deroulement d'une partie -----
% --------------------------------------------------------

% ----- Qui commence la partie? -----

qui_commence:-
	write('Qui commence ? j1 ou j2'),nl,nl,
	read(Qui),nl,
	retractall(tourdujoueur(_)),
	asserta(tourdujoueur(Qui)).

% ----- DemandeCoup suivant le type de partie (JvJ , JvO , OvO) -----

% ---- demandecoupJvJ ---- 

demandecoupJvJ(Coup):-
	tourdujoueur(J),
	J == j1,!,
	write('Tour du joueur 1'),nl,
	write('Entrer votre coup de la maniere suivante : "[_,Deplacement,ResAGarder,ResaJeter]"'),nl,
	read(Coup),
	Coup = [J,_,_,_].

demandecoupJvJ(Coup):-
	tourdujoueur(J),
	J == j2,!,
	write('Tour du joueur 2'),nl,
	write('Entrer votre coup de la maniere suivante : "[_,Deplacement,ResAGarder,ResaJeter]"'),nl,
	read(Coup),
	Coup = [J,_,_,_].
	
% ---- demandecoupJvO ----	

demandecoupJvO(Coup):-
	tourdujoueur(J),
	J == j1,!,
	write('Cest votre tour'),nl,
	write('Entrer votre coup de la maniere suivante : "[_,Deplacement,ResAGarder,ResaJeter]"'),nl,
	read(Coup),
	Coup = [J,_,_,_].

demandecoupJvO(Coup):-
	tourdujoueur(J),
	J == j2,!,
	write('Cest le Tour de l ordinateur'),nl,
	plateau(Plateau),
	meilleur_coup(Plateau,Coup),
	write('Coup de l ordinateur :'),write(Coup),nl,nl.

% ---- demandecoupOvO ----
	
demandecoupOvO(Coup):-
	tourdujoueur(J),
	J == j1,!,
	write('Cest le Tour de l ordinateur1'),nl,
	plateau(Plateau),
	meilleur_coup(Plateau,Coup),
	write('Coup de l ordinateur1 :'),write(Coup),nl,nl.

demandecoupOvO(Coup):-
	tourdujoueur(J),
	J == j2,!,
	write('Cest le Tour de l ordinateur2'),nl,
	plateau(Plateau),
	meilleur_coup(Plateau,Coup),
	write('Coup de l ordinateur2 :'),write(Coup),nl,nl.
	
% ----- Compter les points à la fin du jeu -----

% compterP(Bourse,Reserve,Nbpoints) : retourne le nbpoints d'un joueur en fonction de la bourse du plateau et de la réserve actuelle du joueur
compterP(_,[],0).
compterP(Bourse,[X|Y],N):-
	compterP(Bourse,Y,N1),valMarchandiseEnBourse(Bourse,X,Valeur),N is N1+Valeur, N>0 .

% CompterPoints : Compte les points de chaque joueurs et affiches les scores.
compterPoints(PtsJ1,PtsJ2):-
	plateau(Plateau),
	Plateau = [_,Bourse,_,ReserveJ1,ReserveJ2],
	compterP(Bourse,ReserveJ1,PtsJ1),
	compterP(Bourse,ReserveJ2,PtsJ2),
	write('------    Score final   ------'),nl,nl,
	write('Score du Joueur 1 : '),write(PtsJ1),nl,
	write('Score du Joueur 2 : : '),write(PtsJ2),nl,nl.

% ----- Resultat de la partie -----

% finJeu : Affiche le resultat de la partie. ( qui a gagne).
finJeu(PtsJ1,PtsJ2):-
	PtsJ1 < PtsJ2,!,
	write('Le joueur 2 a gagne'),nl.
	
finJeu(PtsJ1,PtsJ2):-
	PtsJ1 > PtsJ2,!,
	write('Le joueur 1 a gagne'),nl.
	
finJeu(PtsJ1,PtsJ2):-
	PtsJ1 == PtsJ2,!,
	write('Il y a egalite'),nl.

% ----- Boucles de Jeu -----

boucle_jeu_JvJ:- repeat, jeuJvJ, !.
jeuJvJ:-
	plateau(Plateau),nl,nl,
	demandecoupJvJ(Coup),jouer_coup(Plateau,Coup,NouveauPlateau),
	retractall(plateau(_)),asserta(plateau(NouveauPlateau)),nl,nl,nl,nl,nl,nl,
	affiche_plateau(NouveauPlateau),
	NouveauPlateau=[M,_,_,_,_],nbpilesMarchandises(M,Nbpiles),!,Nbpiles =< 2 .

boucle_jeu_JvO:- repeat, jeuJvO, !.
jeuJvO:-
	plateau(Plateau),nl,nl,
	demandecoupJvO(Coup),jouer_coup(Plateau,Coup,NouveauPlateau),
	retractall(plateau(_)),asserta(plateau(NouveauPlateau)),nl,nl,nl,nl,nl,nl,
	affiche_plateau(NouveauPlateau),
	NouveauPlateau=[M,_,_,_,_],nbpilesMarchandises(M,Nbpiles),!,Nbpiles =< 2 .
	
boucle_jeu_OvO:- repeat/*,read(X) seulement pr voir coup par coup les ordi*/, jeuOvO, !.
jeuOvO:-
	plateau(Plateau),nl,nl,
	demandecoupOvO(Coup),jouer_coup(Plateau,Coup,NouveauPlateau),
	retractall(plateau(_)),asserta(plateau(NouveauPlateau)),nl,nl,nl,nl,nl,nl,
	affiche_plateau(NouveauPlateau),
	NouveauPlateau=[M,_,_,_,_],nbpilesMarchandises(M,Nbpiles),!,Nbpiles =< 2 .

% Remarque : la seule chose qui change dans chaqune de ces boucles est la fonction "demandecoup".

% ----- Menu -----

boucle_menu:- repeat, menu, !.
menu:- nl,nl,
	write('1. Partie Joueur vs Joueur'),nl,
	write('2. Partie Joueur vs Ordinateur'),nl,
	write('3. Partie Ordinateur vs Ordinateur'),nl,
	write('4. Quittez le programme'),nl,nl,
	write('Entrer un choix'),nl,
	read(Choix),nl, appel(Choix),
	Choix=4, nl.
	
appel(1):- write('Vous avez choisi le mode : Joueur Vs Joueur'),nl,plateau_depart(_),aff_jeu_depart,qui_commence,boucle_jeu_JvJ,compterPoints(PtsJ1,PtsJ2),!,finJeu(PtsJ1,PtsJ2),!.
appel(2):- write('Vous avez choisi le mode : Joueur vs Ordinateur'),nl,plateau_depart(_),aff_jeu_depart,qui_commence,boucle_jeu_JvO,compterPoints(PtsJ1,PtsJ2),!,finJeu(PtsJ1,PtsJ2),!.
appel(3):- write('Vous avez choisi le mode : Ordinateur vs Ordinateur'),nl,plateau_depart(_),aff_jeu_depart,qui_commence,boucle_jeu_OvO,compterPoints(PtsJ1,PtsJ2),!,finJeu(PtsJ1,PtsJ2),!.
appel(4):- write('Au revoir'),!.
appel(_):- write('Vous avez mal choisi').

% ----- Lancer le jeu : -----

lancer_jeu :- boucle_menu.


	/* ANNEXES
% ---- Trouver le meilleur coup parmis cette liste ----

 Algo :

Remarque : L algo ci-dessous valorise la recherche de la meilleure ressource à garder.

L_Res_TrieParVal[6] = Trie(Ressources);
L_Res_AJeterEnPriorite[6] = Tri2(Ressources);
	Pour i allant de 0 à 6 faire:
		Pour j allant de 0 à 6 faire:
			Si L_Res_TrieParVal[i] appartient à un Coup de ListeCoupsPossibles AND L_Res_AJeterEnPriorite[j] appartient à ce même coup alors
				Meilleur_coup = Coup.
	
Remarque :  L algo ci-dessous valorise la recherche de la meilleure ressource à jeter.	

L_Res_TrieParVal[6] = Trie(Ressources);
L_Res_AJeterEnPriorite[6] = Tri2(Ressources);
	Pour i allant de 0 à 6 faire:
		Pour j allant de 0 à 6 faire:
			Si L_Res_TrieParVal[j] appartient à un Coup de ListeCoupsPossibles AND L_Res_AJeterEnPriorite[i] appartient à ce même coup alors
				Meilleur_coup = Coup.


% --- trieResParVal(RessourcesTriées) :  Renvoie la liste des ressources en bourses triés par valeur décroissantes. ---

concat([],L,L).
concat([T|Q],L2,[T|R]):-concat(Q,L2,R).

inverse([],[]).
inverse([T|Q],R):-inverse(Q,Z),concat(Z,[T],R).

partitionB(_,[],[],[]).
partitionB(Pivot,[[RES,T]|Q],[[RES,T]|L1],L2):- T =< Pivot , partitionB(Pivot,Q,L1,L2).
partitionB(Pivot,[[RES,T]|Q],L1,[[RES,T]|L2]):- T > Pivot , partitionB(Pivot,Q,L1,L2). 
	
trieB([],[]).
trieB([[RES,T]|Q],R):-
	partitionB(T,Q,L1,L2),
	trieB(L1,R1),
	trieB(L2,R2),
	concat(R1,[RES],R3),
	concat(R3,R2,R).

trieResParVal(RessourcesTriees):-
	plateau(Plateau),
	Plateau = [_,Bourse,_,_,_],
	trieB(Bourse,R1),
	inverse(R1,RessourcesTriees).
	
% --- trieResAjeter(L_Res_AJeterEnPrioriteJ1,L_Res_AJeterEnPrioriteJ2) renvoie les listes des ressources à jeter en priorité du J1 et J2  dans l'ordre decroissant. ---


listeRessourceValeur([],[],[]).  Renvoie le "taux_d'importance_de_jeter" de chaque ressource du J1 et du J2  (les listes ont la même forme que la Bourse) 
listeRessourceValeur([[RES,T]|Q],ListeRessourceValeurJ1,ListeRessourceValeurJ2):-
	plateau(Plateau),
	Plateau = [_,_,_,ReserveJ1,ReserveJ2],
	occurrence(ReserveJ1,RES,NbResJ1),
	occurrence(ReserveJ2,RES,NbResJ2),
	TotJ1 is NbResJ1 * T,  Score associé a cette ressource = Nombre de Ressource en Réserve * Sa valeur en bourse 
	TotJ2 is NbResJ2 * T,
	TauxJ1 is TotJ2 - TotJ1,  Plus le taux est élevé plus il vaut mieux Jeter cette ressource (taux = Score adversaire - Son score) 
	TauxJ2 is TotJ1 - TotJ2,
	ajout_Elem_L([RES,TauxJ1],L1, ListeRessourceValeurJ1),
	ajout_Elem_L([RES,TauxJ2],L2, ListeRessourceValeurJ2),
	listeRessourceValeur(Q,L1,L2).
	
	
trieResAjeter(L_Res_AJeterEnPrioriteJ1,L_Res_AJeterEnPrioriteJ2):-
	plateau(Plateau),
	Plateau = [_,Bourse,_,_,_],
	listeRessourceValeur(Bourse,L1,L2),
	trieB(L1,R1),
	trieB(L2,R2),
	inverse(R1,L_Res_AJeterEnPrioriteJ1),
	inverse(R2,L_Res_AJeterEnPrioriteJ2).
	
% --- Meilleur_coup renvoie le meilleur coup en fonction du plateau actuel ---	

x_y_appartient_a_LCoup(X,Y,[[A,B,X,Y]|_],[A,B,X,Y]).
x_y_appartient_a_LCoup(X,Y,[_|Q],R):- x_y_appartient_a_LCoup(X,Y,Q,R).

fonction(_,[],_,[]).
fonction([T1|Q1], [T2|Q2], L, [R1|R]) :- x_y_appartient_a_LCoup(T1,T2,L,R1), fonction([T1|Q1], Q2, L, R), !.
fonction([T1|Q1], [_|Q2], L, R) :- fonction([T1|Q1], Q2, L, R).

fonction2([],_,_,[]).
fonction2([T1|Q1], [T2|Q2], L, R) :- fonction([T1|Q1], [T2|Q2], L, Tmp1), fonction2(Q1, [T2|Q2], L, Tmp2), concat(Tmp1, Tmp2, R), !.


 OPTIMISATION : Il faudrait mettre à la fin de L_coupTRiee les coups du type : [_,_,RES,RES] car c'est un peu con a faire.

Une autre possibilité d'algo serait de :
Attribuer un score à chacun des coups et choisir celui qui a le score le plus élevé,au lieu de préconiser les ResAGarder ou les ResAJeter 
(car dans notre cas, l'ordi peut tres bien garder la meilleure ressource a garder mais jeter une ressource qu'il possède beaucoup...).


meilleur_coup2(Plateau,Meilleur_coup):-		
	tourdujoueur(Joueur),
	Joueur == j1,!,
	coups_possibles(Plateau,ListeCoupsPossibles),
	trieResParVal(RessourcesTriees),
	write('RessourcesAGarder'),write(RessourcesTriees),nl,
	trieResAjeter(L_Res_AJeterEnPrioriteJ1,_),
	write('RessourcesAJeter'),write(L_Res_AJeterEnPrioriteJ1),nl,	
	fonction2(RessourcesTriees,L_Res_AJeterEnPrioriteJ1,ListeCoupsPossibles,L_coupTRiee),
	L_coupTRiee=[Meilleur_coup|_].

meilleur_coup2(Plateau,Meilleur_coup):-
	tourdujoueur(Joueur),
	Joueur == j2,!,
	coups_possibles(Plateau,ListeCoupsPossibles),
	trieResParVal(RessourcesTriees),
	write('RessourcesAGarder'),write(RessourcesTriees),nl, 
	trieResAjeter(_,L_Res_AJeterEnPrioriteJ2),
	write('RessourcesAJeter'),write(L_Res_AJeterEnPrioriteJ2),nl, 
	fonction2(RessourcesTriees,L_Res_AJeterEnPrioriteJ2,ListeCoupsPossibles,L_coupTRiee),
	L_coupTRiee=[Meilleur_coup|_].
	
*/