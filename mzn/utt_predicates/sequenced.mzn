%%%%%%%%%%%% SEQUENCEMENT
% séquencement d'1 n-uplet de séances
predicate sequenced(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : sequenced");
  int: a1 = my_trace(u_lupredicate,"1 tuple de séances",my_show("S",sessions,true));
  } in
  if h == hard then 
  if(length(sessions) == 1)then 
    true
  else
    forall(i,j in index_set(sessions) where i<j)(
      x_slot[sessions[i]]+session_length(sessions[i]) <= x_slot[sessions[j]]
    )
    endif
  endif
 ;

% séquencement de 2 n-uplets de séances
predicate sequenced(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : sequenced");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
  %Definis [1,2] [3,4,5] -> (1 op 3) (1 op 4) (1 op 5) (2 op 3)(2 op 4)(2 op 5)
  x_slot[sessions1[1]]+session_length(sessions1[1]) <= x_slot[sessions2[1]] /\ sequenced(r,h,n, types,elements,sessions1,parameters)/\ sequenced(r,h,n, types,elements,sessions2,parameters)
 ;

% séquencement d'1 n-uplet de n-uplets alignés de séances
predicate sequenced(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : sequenced");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
  forall(i in T1)(sequenced(r,h,n,types,elements,unpad_quple(sessions[i..i,SESSION]),unpad_quple(sessions[i+1..i+1,SESSION]),parameters)); %TODO revoir types,elements
