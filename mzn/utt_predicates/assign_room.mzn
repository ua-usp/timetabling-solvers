%%%%%%%% assign room
%Pour un ensemble de séance on affecte le prof suivant
% assign_room d'1 n-uplet de séances
predicate assign_room(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : assign_room");
  int: a1 = my_trace(u_lupredicate,"1 tuple de séances",my_show("S",sessions,true));
  set of int: T = index_set(parameters); 
  int: t = card(T);
  array[int] of int: paremeters_linear = [parameter_value[parameters[i],1]|i in T];
  set of int : setRoom = array2set(paremeters_linear);
 % bool: checkNumberParameters = assert(t==1,"Higly number of parameter" ++ show(t),true);
 % bool: checkParametersType = assert(parameter_type[parameters[1]] == "slot","Wrong type of parameter" ++ parameter_type[parameters[1]],true);
  } in
  forall(i in index_set(sessions))(x_rooms[sessions[i]]==setRoom)
;


% assignRoom d'1 n-uplet de n-uplets alignés de séances
predicate assign_room(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : assign_room");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
  
 forall(i in T)(
 let{
   array[int] of SESSION_V: lola=[sessions[i,j]|j in index_set_2of2(sessions)];
 }in
 assign_room(r,h,1,[types[i]],[elements[i]],lola,parameters) % TODO revoir types,elements
 )
 ;
