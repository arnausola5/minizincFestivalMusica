include "globals.mzn";

% ENTRADA
int: nPeces;
array[1..nPeces] of int: durada;
int: nInstruments;
array[1..nPeces, 1..nInstruments] of int: requereix;
int: nMusics;
array[1..nMusics, 1..nInstruments] of bool: saptocar;
int: pressupost;
array[1..nMusics] of int: salari;
int: nPrecs;
array[1..nPrecs] of int: pred;
array[1..nPrecs] of int: succ;

set of int: MUSICS = 1..nMusics;

% VARIABLES
array[1..nPeces] of var 0..sum(durada): startPeces;
array[1..nInstruments, 1..nPeces] of var set of MUSICS: instrumentPeca;
var int: fi = max([durada[i] + startPeces[i] | i in 1..nPeces]);
var int: cost = sum([salari[t] * durada[j] div 5 | i in 1..nInstruments, j in 1..nPeces, t in instrumentPeca[i,j]]);

% CONSTRAINTS
  % Cada peca tingui els instruments que li toquen
constraint forall(i in 1..nInstruments, j in 1..nPeces) (card(instrumentPeca[i,j]) = requereix[j, i]);

  % Cada músic sàpiga tocar el seu instrument
constraint forall(i in 1..nInstruments, j in 1..nPeces, m in instrumentPeca[i,j]) (saptocar[m,i]);


  % Que cada músic només pugui tocar una peça alhora
constraint forall(i in 1..nMusics) (cumulative(startPeces, durada, [if i in array_union(col(instrumentPeca, j)) then 1 else 0 endif | j in 1..nPeces], 1));

  % Que no intenti posar més intruments dels necessaris
constraint forall(i in 1..nInstruments) (cumulative(startPeces, durada, [requereix[j,i] | j in 1..nPeces], sum(col(saptocar,i))));                              
                                                                                                                  
  % Que cada peça tingui músics diferents
constraint forall(i in 1..nPeces) (card(array_union([instrumentPeca[t,i] | t in 1..nInstruments])) = sum(row(requereix, i)));
                                       
  % Calculem els temps que comença cada peça
% constraint cumulative(startPeces, durada, [1 | i in 1..nPeces], nPeces - max([max([count(pred, i), count(succ, i)]) | i in 1..nPrecs]) + 1);

  % No toquin més músics dels que tens alhora
constraint cumulative(startPeces, durada, [sum(row(requereix, i)) | i in 1..nPeces], nMusics);

  % Mirem que el preu total no passi el pressupost
constraint cost <= pressupost;

  % Complim les precedències
constraint forall(i in 1..nPrecs) (startPeces[pred[i]] + durada[pred[i]] <= startPeces[succ[i]]);


solve minimize fi;

output ["Hora d'inici del festival: 10h 0min\n" ++
        "Hora d'acabada del festival: " ++ show(10 + (fi div 60)) ++ "h " ++ show(fi mod 60) ++ "min\n" ++
        "Cost de contractacio: " ++ show(cost) ++ " euros\n"] ++

        [ if i == 1 then
            "Peca " ++ show(p) ++ ":\n" ++
            "\tInici: " ++ show(10 + (startPeces[p] div 60)) ++ "h " ++ show(startPeces[p] mod 60) ++ "min\n" ++
            "\tFinal: " ++ show(10 + ((startPeces[p]+durada[p]) div 60)) ++ "h " ++ show((startPeces[p]+durada[p]) mod 60) ++ "min\n"
          else "" endif ++
          if card(fix(instrumentPeca[i,p])) != 0 then "\tL'intrument " ++ show(i) ++ " el toquen " ++ show(fix(instrumentPeca[i,p])) ++ "\n" else "" endif | p in 1..nPeces, i in 1..nInstruments ];