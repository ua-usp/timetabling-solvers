%%%%%%%% FORBIDDEN SLOT

%Bloque pour un filtrage particulier bloque les l'intervalles de disponibilité
% forbiddenSlots d'1 n-uplet de séances
predicate forbidden_slots(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : forbidden_slots");
  int: a1 = my_trace(u_lupredicate,"1 tuple de séances",my_show("S",sessions,true));
  int: y = search_value_name(parameters,"first");
  bool: size_is_ok = assert(y!=-1,"Size of parameters is bad y = "  ++ show(y),true);
  int: x = search_value_name(parameters,"last");
  bool: size_is_ok_ = assert(x!=-1,"Size of parameters is bad x = " ++ show(x),true);
  } in
forall(i in index_set(sessions))(
(x_slot[sessions[i]] < parameter_value[y,1]) \/  (x_slot[sessions[i]]>parameter_value[x,1])
)
;

% forbiddenSlots de 2 n-uplets de séances
predicate forbidden_slots(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : forbidden_slots");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
true
;

% forbiddenSlots d'1 n-uplet de n-uplets alignés de séances
predicate forbidden_slots(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : forbidden_slots");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
 true;
