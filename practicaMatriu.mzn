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

% VARIABLES
array[1..nPeces] of var 0..sum(durada): startPeces;
array[1..nMusics, 1..nPeces] of var 0..nInstruments: musicPeca;
var int: fi = max([durada[i] + startPeces[i] | i in 1..nPeces]);
var int: cost = sum([if musicPeca[i,j] = 0 then 0 else durada[j] div 5 * salari[i] endif | i in 1..nMusics, j in 1..nPeces]);

% CONSTRAINTS
  % Cada peca tingui els instruments que li toquen
constraint forall(i in 1..nPeces, j in 1..nInstruments) (count(col(musicPeca, i), j, requereix[i, j]));
 
  % Que cada músic toqui un instrument que sapiga tocar
constraint forall(i in 1..nMusics, j in 1..nPeces) (if musicPeca[i,j] = 0 then true else saptocar[i, musicPeca[i,j]] endif);

  % Que cada músic només pugui tocar una peça alhora
constraint forall(i in 1..nMusics) (cumulative(startPeces, durada, [if musicPeca[i,j] != 0 then 1 else 0 endif | j in 1..nPeces], 1));

  % Que no intenti posar més intruments dels necessaris    
constraint forall(i in 1..nInstruments) (cumulative(startPeces, durada, [requereix[j,i] | j in 1..nPeces], sum(col(saptocar,i))));
                                            
  % Calculem els temps que comença cada peça
% constraint cumulative(startPeces, durada, [1 | i in 1..nPeces], nPeces);

  % Que no intentis tocar dos peçes alhora que requereixen més músics dels que tens
constraint cumulative(startPeces, durada, [sum(row(requereix, i)) | i in 1..nPeces], nMusics);

  % Mirem que el preu total no passi el pressupost
constraint cost <= pressupost;
  
  % Complim les precedències
constraint forall(i in 1..nPrecs) (startPeces[pred[i]] + durada[pred[i]] <= startPeces[succ[i]]);

solve minimize fi;
        
output ["Hora d'inici del festival: 10h 0min\n" ++
        "Hora d'acabada del festival: " ++ show(10 + (fi div 60)) ++ "h " ++ show(fi mod 60) ++ "min\n" ++
        "Cost de contractacio: " ++ show(cost) ++ " euros\n"] ++

        [ if (m == 1) then
            "Peca " ++ show(p) ++ ":\n" ++
            "\tInici: " ++ show(10 + (startPeces[p] div 60)) ++ "h " ++ show(startPeces[p] mod 60) ++ "min\n" ++
            "\tFinal: " ++ show(10 + ((startPeces[p]+durada[p]) div 60)) ++ "h " ++ show((startPeces[p]+durada[p]) mod 60) ++ "min\n"
          else "" endif ++
          if (fix(musicPeca[m,p]) != 0) then "\tMusic " ++ show(m) ++ " toca instrument " ++ show(musicPeca[m,p]) ++ "\n" else "" endif | p in 1..nPeces, m in 1..nMusics];