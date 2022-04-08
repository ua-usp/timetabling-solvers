%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FONCTIONS UTILITAIRES
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONVERSION DE TABLEAUX
  
% convertit le tableau bi-dimensionnel `T` en un tableau uni-dimensionnel
function array[int] of int: array_2d_to_1d(array[int,int] of int: T) =
  [T[i,j] | i in index_set_1of2(T), j in index_set_2of2(T)];

% convertit le tableau bi-dimensionnel `T` en un tableau uni-dimensionnel
function array[int] of string: array_2d_to_1d(array[int,int] of string: T) =
  [T[i,j] | i in index_set_1of2(T), j in index_set_2of2(T)];

% convertit le tableau bi-dimensionnel `T` en un tableau uni-dimensionnel
function array[int] of set of int: array_2d_to_1d(array[int,int] of set of int: T) =
  [T[i,j] | i in index_set_1of2(T), j in index_set_2of2(T)];

% lifte le tableau uni-dimensionnel `T` en un tableau bi-dimensionnel à 1 ligne
function array[int,int] of int: array_1d_to_2d(array[int] of int: T) =
  array2d(1..1,index_set(T),T);

% lifte le tableau uni-dimensionnel `T` en un tableau bi-dimensionnel à 1 ligne
function array[int,int] of string: array_1d_to_2d(array[int] of string: T) =
  array2d(1..1,index_set(T),T);

% lifte le tableau uni-dimensionnel `T` en un tableau bi-dimensionnel à 1 ligne
function array[int,int] of set of int: array_1d_to_2d(array[int] of set of int: T) =
  array2d(1..1,index_set(T),T);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TUPLES, TUPLES ALIGNES
%%%
%%% Soient :
%%% - `s` un entier positif
%%% - `D` un ensemble fini quelconque
%%% - `u` un élément n'appartenant pas à `D`, appelé *padder*
%%% - `E` l'union de `D` et `{u}`, appelé domaine d'alignement.
%%%
%%% L'ensemble des tuples à valeurs dans `D` de taille inférieure à `s` est en bijection avec l'ensemble des tuples dits *alignés* :
%%% - à valeurs dans `E`
%%% - de taille `s`
%%% - et ne comportant aucune occurrence de `u` précédant une occurrence d'élément de `D`.
%%%
%%% Tout tuple aligné se termine par une répétition, éventuellement vide, du padder, et s'interprète par sa restriction aux valeurs de `D`.
%%%
%%% Les opérations sur tuples s'implément sur leurs alignements (alias padding) sur une plage de taille prédéfinie :
%%% - padding : la conversion de tuple en tuple aligné s'effectue par remplissage avec le padder.
%%% - unpadding : la réciproque s'implémente par suppression des padders.
%%% - concaténation : la concaténation de deux tuples s'effectue par unpadding des tuples alignés, concaténation des tuples résultants, et padding du tuple résultant.
%%% - projection : la projection d'un tuple s'effectue par projection du tuple aligné sur les composantes visées (nécessairement non-nulles) puis padding du tuple résultant.
%%% - permutation : la permutation d'un tuple s'effectue par permutation des composantes non-nulles du tuple aligné.
%%%

%% PADDING/ALIGNEMENT
% renvoie l'alignement du tuple `T` sur la plage `1..s` en le complétant avec une suite, potentiellement vide, de padders `padder`
function array[int] of int: pad_tuple(array[int] of int: T, int: s, int: padder) =
  let {
  set of int: N = index_set(T);
  bool: checkarg1 = assert(N==1..card(N),"index set is not a standard-range" ++ show(T),true);
  bool: checkarg2 = assert(s>=length(T),"impossible padding",true);
  } in
  T ++ [ padder | i in 1..s-length(T)];

%% UNPADDING/DESALIGNEMENT
% renvoie le tuple obtenu en supprimant toute occurrence du padder `padder` dans le tuple aligné `T`
function array[int] of int: unpad_tuple(array[int] of int: T, int: padder) =
  let {
  set of int: N = index_set(T);
  bool: checkarg1 = assert(N==1..card(N),"index set is not a standard-range" ++ show(T),true);
  bool: checkarg2 = assert(forall(i in min(N)..max(N)-1)(T[i]==padder -> T[i+1]==padder),"non-consecutive padders in '" ++ show(T) ++ " (reserved padding symbol/value)",true);
  } in
  [ T[i] | i in N where T[i]!=padder];
  
 % renvoie le tuple obtenu en supprimant toute occurrence du padder `padder` dans la première et supposée seule ligne du tableau `T`, échoue sinon
function array[int] of int: unpad_tuple(array[int,int] of int: T, int: padder) =
  let {
  bool: checkarg1 = assert(card(index_set_1of2(T))==1,"expecting single-line array " ++ show(T),true);
  } in
  unpad_tuple(array_2d_to_1d(T),padder);
  
  
%% PRODUIT CARTESIEN D'ENSEMBLES DE TUPLES
% renvoie l'ensemble des tuples du produit cartésien sous forme de tableau de tuples alignés chacun avec un padder `padder`
% - les ensembles de départ sont représentés chacun sous forme de tableaux qui sont empilés dans un unique de tableau de tuples alignés `E`
% - leurs tailles respectives sont données dans un tableau de dimensionnement `cardinality`
function array[int,int] of int: cartesian_product(array[int,int] of int: E, array[int] of int: cardinality) =
  let {
  set of int: M = index_set_1of2(E); % plage du tableau de tuples 
  int: a1 = my_trace(u_lutils,"M",M);
  bool: checkarg1 = assert(M==1..card(M),"row index set of tuple array is not a standard-range",true);
  set of int: N = index_set_2of2(E); % plage d'alignement du tableau de tuples 
  bool: checkarg2 = assert(N==1..card(N),"column index set of tuple array is not a standard-range",true);
  int: m = card(M);
  int: a222 = my_trace(u_lutils,"CARDINALITY",cardinality);
  bool: checkarg3 = assert(m=sum(cardinality),"tuple array and cardinality array have different sizes",true);
  int: arity = length(cardinality);
  set of int: ARITY = index_set(cardinality);
  int: a2 = my_trace(u_lutils,"ARITY",ARITY);
  bool: checkarg4 = assert(ARITY==1..length(ARITY),"index set of cardinality array is not a standard-range",true);
  int: first = min(ARITY);
  int: last = max(ARITY);
  array[ARITY] of int: modulo = [product(j in ARITY where j>i)(cardinality[j]) | i in ARITY diff {last}] ++ [1];
  int: a3 = my_trace(u_lutils,"modulo",modulo);
  int: a4 = my_trace(u_lutils,"is_modulo",index_set(modulo));
  array[ARITY] of int: offset = if arity!=200 then [1] ++  [1 + sum(j in ARITY where j<i)(cardinality[j]) | i in ARITY diff {first}] else[1] ++  [sum(j in ARITY where j<i)(cardinality[j]) | i in ARITY diff {first}]endif;
  int: a5 = my_trace(u_lutils,"offset",offset);
  int: a6 = my_trace(u_lutils,"is_offset",index_set(offset));
  int: size = arity*product(cardinality);%if arity*product(cardinality)=1536 then 26 else arity*product(cardinality) endif;
  int: a7 = my_trace(u_lutils,"size",size);
  set of int: SIZE = 1..size;
  %TODO revoir et documenter
  array[SIZE] of M: lookup = %[((((n div modulo[1 + ((n-1) mod arity)]) mod m) + offset[(1+((n-1) mod arity))] )mod m)+1|n in SIZE];
  [ (((((((n div arity) div modulo[1 + ((n-1) mod arity)]))mod cardinality[(1+((n-1) mod arity))])) + offset[(1+((n-1) mod arity))] ))|n in SIZE];
  %if sum(i in ARITY)(cardinality[i])==arity then
  %[(((n mod m) div modulo[1 + ((n-1) mod arity)]) + offset[(1+((n-1) mod arity))] ) mod m+1| n in SIZE]
  %else [(((n div arity) div modulo[1 + ((n-1) mod arity)]) + offset[(1+((n-1) mod arity))] ) mod m+1| n in SIZE]endif;
  int: a8 = my_trace(u_lutils,"lookup",lookup);
  } in
  array2d(SIZE,N,[E[lookup[n],j] | n in SIZE, j in N]);
  
%TODO documenter
function array[int,int] of int: stack_arrays(array[int,int] of int: T1, array[int,int] of int: T2) =
  let {
  set of int: M1 = index_set_1of2(T1);
  set of int: M2 = index_set_1of2(T2);
  set of int: N1 = index_set_2of2(T1);
  set of int: N2 = index_set_2of2(T2);
  bool: checkarg1 = assert(N1==1..card(N1),"index set of first array is not a standard-range",true);
  bool: checkarg2 = assert(N2==N1,"index sets of arrays are different",true);
  } in
  array2d(1..card(M1)+card(M2),N1,array_2d_to_1d(T1)++array_2d_to_1d(T2));
  








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONVERSION ENSEMBLES-TABLEAUX

% % convertit le tableau uni-dimensionnel d'entiers `T` en un ensemble d'entiers
% function set of int: array_to_set(array[int] of int: T) =
%   {T[i] | i in index_set(T)};
  
% % convertit l'ensemble d'entiers `S` en un tableau d'entiers triés en ordre croissant (aplanissement)
% function array[int] of int: set_to_array(set of int: S) =
%   [i | i in S];
  
% aplanit les ensembles du tableau `T` et renvoie le tableau les concaténant
% function array[int] of int: sets_to_array(array[int] of set of int: T) =
%  [i | j in index_set(T), i in T[j]]; 
%   if card(index_set(T))==1
%   then set2array(T[min(index_set(T))])
%   else set2array(T[min(index_set(T))])  ++ sets_to_array(T[min(index_set(T))+1..max(index_set(T))])
%   endif;


% % renvoie le tuple vide si `t` ne contient que des occurences de `padder`, sinon renvoie sa concaténation avec une occurence de `delimiter`
% function array[int] of int: tuplify(array[int] of int: T, int: padder, int: delimiter) =
%   if forall(i in index_set(T))(T[i]==padder)
%   then []
%   else T ++ [delimiter]
%   endif;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ENSEMBLES DE TUPLES, PRODUIT CARTESIEN
%%%
%%% Un ensemble de tuples représentés sous forme alignée se représente par un tuple aligné :
%%% - en adjoignant au domaine des tuples un nouvel élément dit *t-délimiteur* (délimiteur de tuples)
%%% - en faisant suivre chaque tuple désaligné par une unique occurence du t-délimiteur
%%% - en alignant le tuple résultat avec le padder sur une plage donnée.
%%%
  
% %% DEPLIEMENT DE LISTE DE TUPLES ALIGNES
% % déplie la liste `L` de tuples alignés avec le padder  `padder` en utilisant le délimiteur `delimiter` et padder  `padder` sur la plage `1..d`
% function array[int] of int: unfold_tuples_list(array[int,int] of int: L, int: padder, int: delimiter, int: d) =
%   let {
%   int: a0 = my_trace(u_lutils,"Unfold list of tuples",show(L));
%   set of int: M = index_set_1of2(L);
%   int: m = card(M); % nombre de tuples
%   bool: checkarg0 = assert(m>0,"liste vide " ++ show(L),true);
%   set of int: N = index_set_2of2(L); % plage d'alignement des tuples
%   int: n = card(N); % taille d'alignement des tuples
%   bool: checkarg1 = assert(N==1..card(N),"plage d'alignement non normée des tuples de " ++ show(L),true);
%   bool: checkarg2 = assert(forall(i in M, j in min(N)..max(N)-1)(L[i,j]==padder -> L[i,j+1]==padder),"padders non-consécutifs dans " ++ show(L) ++ " (caractère de padding réservé)",true);
% %  array[int] of int: D = [L[i,j] | i in M, j in N where L[i,j]!=padder]; % liste des valeurs des tuples
%   bool: checkarg3 = assert(d>=sum(i in M)(1+length([L[i,j] | j in N where L[i,j]!=padder])),"taille d'alignement " ++ show(d) ++ " insuffisante pour l'ensemble de tuples " ++ show(L),true);
%   bool: checkarg4 = assert(d==2*n,"taille d'alignement " ++ show(d) ++ " inconsistante avec la taille d'alignement " ++ show(L) ++ " des tuples de " ++ show(L) ,true);
%   } in
%   pad_tuple(unfold_tuples_list_(L,padder,delimiter),d,padder);

% % déplie la liste `L` de tuples alignés avec le padder  `padder` et supposés disjoints en utilisant le délimiteur `delimiter`
% function array[int] of int: unfold_tuples_list_(array[int,int] of int: L, int: padder, int: delimiter) =
%   let {
%   set of int: M = index_set_1of2(L);
%   int: m = card(M); % nombre de tuples
%   bool: checkarg0 = assert(m>0,"liste vide " ++ show(L),true);
%   set of int: N = index_set_2of2(L); % plage d'alignement des tuples
%   int: n = card(N); % taille d'alignement des tuples
%   bool: checkarg1 = assert(N==1..card(N),"plage d'alignement non normée des tuples de " ++ show(L),true);
%   bool: checkarg2 = assert(forall(i in M, j in min(N)..max(N)-1)(L[i,j]==padder -> L[i,j+1]==padder),"padders non-consécutifs dans " ++ show(L) ++ " (caractère de padding réservé)",true);
%   } in
%   if m==1
%   then unpad_tuple(array_2d_to_1d(L),padder) ++ [delimiter]
%   else unpad_tuple(array_2d_to_1d(L[1..1,N]),padder) ++ [delimiter] ++ unfold_tuples_list_(L[2..m,N],padder,delimiter)
%   endif;
  
% %% REPLIEMENT DE TUPLE ALIGNE DE TUPLES DISJOINTS
% % replie le tuple de tuples `T` en supprimant les délimiteurs et en alignant chacun sur la plage d'alignement `1..d` avec le padder
% % - renvoie le tuple nul sur `1..d` si `T` est vide
% function array[int,int] of int: fold_tuples_list(array[int] of int: T, int: padder, int: delimiter, int: d) =
%   let {
% int: a0 = my_trace(u_lutils,"Fold list of tuples T ",show(T));
% %  int: a01 = my_trace(u_lutils,"alignment size ",show(d));
%   set of int: N = index_set(T); % plage de `T`
%   int: n = card(N); % taille de `T`
% %  int: a1 = my_trace(u_lutils,"T size ",show(n));
%   bool: checkarg1 = assert(N==1..card(N),"plage non normée du tuple " ++ show(T),true);
% %  bool: checkarg2 = assert(forall(i in 1..(card(N)-1))(T[i]==padder -> T[i+1]==padder),"padders non-consécutifs dans " ++ show(T) ++ " (caractère de padding réservé)",true);
%   bool: checkarg3 = assert(forall(i in 1..(card(N)-1))(T[i]==delimiter -> T[i+1]!=delimiter),"délimiteurs consécutifs dans " ++ show(T) ++ " (caractère de délimitation réservé)",true);
%   array[int] of N: P=[i | i in N where  T[i]==delimiter]; % positions des délimiteurs
% %  int: a2 = my_trace(u_lutils,"delimiters ",show(P));
%   int: m = length(P); % nombre de tuples dans `T`
% %  int: a3 = my_trace(u_lutils,"#delimiters ",show(m));
%   set of int: M = 1..m; % plage des numéros de tuples
%   } in
%   if index_set(T)=={}
%   then array2d(1..1,1..d,[padder | i in 1..d]) % tuple vide
%   else array2d(M,1..d,fold_tuples_list_(T,padder,delimiter,d))
%   endif;

% % supprime les délimiteurs de la liste des tuples `T` en alignant chacun sur la plage `1..d` avec le padder
% function array[int] of int: fold_tuples_list_(array[int] of int: T, int: padder, int: delimiter, int: d) =
%   let {
%   set of int: N = index_set(T); % plage de `T`
%   array[int] of N: P=[i | i in N where T[i]==delimiter]; % positions des délimiteurs
%   int: m = length(P); % nombre de tuples dans `T`
%   set of int: M = 1..m; % plage des numéros de tuples
% %  int: a1 = my_trace(u_lutils,"N ",show(N));
% %  int: a2 = my_trace(u_lutils,"P ",show(P));
% %  int: a3 = my_trace(u_lutils,"m ",show(m));
%   array[int] of int: t = pad_tuple([T[i] | i in N where i<P[1]],d,padder);
% %  int: a4 = my_trace(u_lutils,"t ",show(t));
%   } in
%   if  m==1
%   then t
%   else  t ++ fold_tuples_list_([T[i] | i in N where i>P[1]],padder,delimiter,d)
%   endif;

% %% CONCATENATION ALIGNEE AVEC DELIMITEUR DE TUPLES ALIGNES DISJOINTS
% % renvoie le tuple concaténant les tuples `T1` et `T2` alignés avec le padder `padder` :
% % - en les désalignant
% % - en insérant une occurence du délimiteur entre eux
% % - en réalignant le tuple résultat sur la plage d'alignement `1..d` avec le même padder
% function array[int] of int: concatenate_tuples(array[int] of int: T1, array[int] of int: T2, int: padder, int: delimiter, int: d) =
%   let {
%   set of int: N1 = index_set(T1);
%   set of int: N2 = index_set(T2);
%   bool: checkarg1 = assert(N1==1..card(N1),"plage d'alignement non normée de " ++ show(T1),true);
%   bool: checkarg2 = assert(N2==1..card(N2),"plage d'alignement non normée de " ++ show(T2),true);
%   bool: checkarg3 = assert(N1==N2,"tuples de plages d'alignement différentes",true);
%   bool: checkarg4 = assert(forall(j in min(N1)..max(N1)-1)(T1[j]==padder -> T1[j+1]==padder),"padders non-consécutifs dans " ++ show(T1) ++ " (caractère de padding réservé)",true);
%   bool: checkarg5 = assert(forall(j in min(N2)..max(N2)-1)(T2[j]==padder -> T2[j+1]==padder),"padders non-consécutifs dans " ++ show(T2) ++ " (caractère de padding réservé)",true);
%   set of int: N = N1;
%   array[int] of int: T = unpad_tuple(T1,padder) ++ [delimiter] ++ unpad_tuple(T2,padder);
%   bool: checkarg6 = assert(length(T)<=card(N),"concaténation non-alignable : tuples non disjoints",true);
%   } in 
%   pad_tuple(T,d,padder);

% function array[int,int] of int: twoArraysProduct(array[int,int] of int: E1, array[int,int] of int: E2, int: padder, int: delimiter, int: d) =
%   let {
%   set of int: M1 = index_set_1of2(E1); % plage du tableau 1 de tuples
%   set of int: M2 = index_set_1of2(E2); % plage du tableau 2 de tuples
%   set of int: N1 = index_set_2of2(E1); % plage d'alignement des tuples du tableau 1
%   set of int: N2 = index_set_2of2(E2); % plage d'alignement des tuples du tableau 2
%   bool: checkarg1 = assert(N1==1..card(N1),"plage d'alignement du tableau " ++ show(E1) ++ " non normée",true);
%   bool: checkarg2 = assert(N2==1..card(N2),"plage d'alignement du tableau " ++ show(E2) ++ " non normée",true);
%   bool: checkarg3 = assert(N1==N2,"tableaux ayant des plages d'alignement incompatibles",true);
%   bool: checkarg4 = assert(forall(i in M1, j in min(N1)..max(N1)-1)(E1[i,j]==padder -> E1[i,j+1]==padder),"padders non-consécutifs dans  " ++ show(E1) ++ " (caractère de padding réservé)",true);
%   bool: checkarg5 = assert(forall(i in M2, j in min(N2)..max(N2)-1)(E2[i,j]==padder -> E2[i,j+1]==padder),"padders non-consécutifs dans  " ++ show(E2) ++ " (caractère de padding réservé)",true);
%   set of int: M = 1..card(M1)*card(M2); % plage du tableau résultat
%   set of int: N = 1..d; % plage d'alignement des tuples du tableau résultat
%   } in 
%   array2d(M,N,[concatenate_tuples(array_2d_to_1d(E1[i1..i1,N1]),array_2d_to_1d(E2[i2..i2,N2]),padder,delimiter,d)[k] | i1 in M1, i2 in M2, k in N]); % TODO optimize : single call

% function array[int,int] of int: arraysProduct(array[int,int] of int: E, array[int] of int: sizes, int: padder, int: delimiter, int: d) =
%   let {
%   set of int: M = index_set_1of2(E); % plage du tableau de tuples 
%   bool: checkarg1 = assert(M==1..card(M),"plage des ensembles non normée",true);
%   bool: checkarg2 = assert(sum(sizes)==card(M),"tableau de tuples de taille incompatible avec le tableau de dimensionnement `sizes`",true);
%   bool: checkarg3 = assert(length(sizes)>1,"nombre d'ensembles de tuples à multiplier de taille <2",true);
%   set of int: M1 = 1..sizes[1]; % plage du premier tableau aggrégé dans `E` représentant le premier ensemble
%   set of int: M2 =sizes[1]+1..card(M); % plage restante des tableaux agrégés dans `E`
%   array[int] of int: left_shift_sizes = sizes[2..length(sizes)]; % tableau de dimensionnement des tableaux restants
%   set of int: N = index_set_2of2(E); % plage d'alignement du tableau de tuples 
%   bool: checkarg4 = assert(N==1..card(N),"plage des tuples non normée",true);
%   bool: checkarg5 = assert(card(M)*card(N)<=d,"taille d'alignement insuffisante",true);
%   } in
%   if length(sizes)==2
%   then twoArraysProduct(E[M1,N],E[M2,N],padder,delimiter,d) % 2 tableaux uniquement à multiplier
%   else twoArraysProduct(E[M1,N],arraysProduct(E[M,N],left_shift_sizes,padder,delimiter,d),padder,delimiter,d)
%   endif;