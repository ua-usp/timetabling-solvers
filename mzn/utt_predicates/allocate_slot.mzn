%%%%%%%% allocateSlot
%Pour un filtrage pariculier lui assigne un slot particulier inverse de forbidden slot
% allocateSlot d'1 n-uplet de séances
predicate allocate_slot(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : allocate slot");
  int: a1 = my_trace(u_lupredicate,"1 tuple de séances",my_show("S",sessions,true));
  set of int: T = index_set(parameters); 
  int: t = card(T);
  array[int] of int: paremeters_linear = [parameter_value[parameters[i],1]|i in T];
  bool: checkNumberParameters = assert(t==1,"Higly number of parameter" ++ show(t),true);
  bool: checkParametersType = assert(parameter_type[parameters[1]] == "slot","Wrong type of parameter" ++ parameter_type[parameters[1]],true);
  } in
  forall(i in index_set(sessions))(x_slot[sessions[i]]==paremeters_linear[1])
;

% allocateSlot de 2 n-uplets de séances
predicate allocate_slot(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : allocate slot");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
true
;

% allocateSlot d'1 n-uplet de n-uplets alignés de séances
predicate allocate_slot(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : allocate slot");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
 forall(i in T)(
 let{
   array[int] of SESSION_V: lola=[sessions[i,j]|j in index_set_2of2(sessions)];
 }in
 allocate_slot(r,h,1,[types[i]],[elements[i]],lola,parameters) % TODO revoir types,elements
 )
 ;
