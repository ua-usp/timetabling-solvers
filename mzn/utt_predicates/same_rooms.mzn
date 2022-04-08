%% SALLES COMMUNES
include "all_equal.mzn";
% salles communes à 1 n-uplet de séances
predicate same_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {%u_lupredicate
  int: a0 = my_trace(true,"U-contrainte : same_rooms");
  int: a1 = my_trace(true,"1 tuple de séances",my_show("S",sessions,true));
  %array[int] 
  } in
  if(length(sessions) >1) then
  forall(s1,s2 in index_set(sessions) where s1<s2)(
    x_rooms[session_class(sessions[s1])] == x_rooms[session_class(sessions[s2])]
  )
  else
    true
  endif
  %all_equal([ x_rooms[session_class(sessions[s])] | s in index_set(sessions)])
  %forall(s1,s2 in index_set(sessions) where s1<s2)(
   % x_rooms[session_class(sessions[s1])] == x_rooms[session_class(sessions[s2])]
 % )
;

% salles communes à 2 n-uplets de séances
predicate same_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : same_rooms");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
  %Definis [1,2] [3,4,5] -> (1 op 3) (1 op 4) (1 op 5) (2 op 3)(2 op 4)(2 op 5)
  if h == hard then
  (x_rooms[sessions1[1]] == x_rooms[sessions2[1]]) /\ same_rooms(r,h,n,types,elements,sessions1,parameters) /\ same_rooms(r,h,n,types,elements,sessions2,parameters)
  /*
    forall(i in index_set(sessions1))(
    %x[i] = x[i+1]
      forall(j in i..max(sessions2))(
     % same_room(% TODO REduire le nbr de contraintes)
        x_rooms[session_class(sessions1[i])] == x_rooms[session_class(sessions2[j])]
      )
    )*/
  endif
;

% salles communes à 1 n-uplet de n-uplets alignés de séances
predicate same_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : same_rooms");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
  forall(i in T1)(same_rooms(r,h,n,types,elements,unpad_quple(sessions[i..i,SESSION]),unpad_quple(sessions[i+1..i+1,SESSION]),parameters)); %TODO revoir types,elements
  
