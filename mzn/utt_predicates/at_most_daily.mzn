 %%%%%%%% ATMOSTDAILY
 %Maximum d'un événement tout les jours
% atMostDaily d'1 n-uplet de séances
/*predicate at_most_daily(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_betatest,"U-contrainte : At most daily");
  int: a1 = my_trace(u_betatest,"1 tuple de séances",sessions);
    %int: a1 = my_trace(u_betatest,"1 tuple de séances",my_show("S",sessions,true));
  
  int:day_slot_count = parameter_value[search_value_name(parameters,"count"),1];
  int:day_slot_min = parameter_value[search_value_name(parameters,"first"),1];
  int:day_slot_max = parameter_value[search_value_name(parameters,"last"),1];
  
  set of int: set_of_day = 1..nr_days_per_week*nr_weeks;
  array[int] of int: minimum_day_slot =[1]++[(nr_slots_per_day*i)+1|i in 2..nr_days_per_week*nr_weeks];
  } in
  forall(i in set_of_day)(
    let{
      array[int] of int : day_concerned = [sessions[j] |j in index_set(sessions) where ((sessions[j]+day_slot_min-1) > (minimum_day_slot[i] + day_slot_min-1))/\ ((sessions[j]+day_slot_max-1) <= (minimum_day_slot[i] + day_slot_max-1))];
    }in
   length(day_concerned) <= day_slot_count
  )
;*/



predicate at_most_daily(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_betatest,"U-contrainte : At most daily");
  int: a1 = my_trace(u_betatest,"1 tuple de séances",sessions);
    %int: a1 = my_trace(u_betatest,"1 tuple de séances",my_show("S",sessions,true));
  
  int:day_slot_count = parameter_value[search_value_name(parameters,"count"),1];
  int:day_slot_min = parameter_value[search_value_name(parameters,"first"),1];
  int:day_slot_max = parameter_value[search_value_name(parameters,"last"),1];
  
  set of int: set_of_minmax = day_slot_min..day_slot_max;
  TYPE : type_element = types[1];
}
in
 if (type_element == teacher) then 
   forall(e in index_set(elements))(
     forall(d in DAY)(
      cumulative(
        [x_slot[s]|s in teacher_sessions(elements[e])],
        [session_length(s)*bool2int( d == slot_day(x_slot[s])/\(e in x_teachers[session_class(s)])  /\ slot_dayslot(x_slot[s]) in set_of_minmax )|s in teacher_sessions(elements[e])],
        [1 | s in teacher_sessions(elements[e])],
        day_slot_count
      )
    )
  )
  elseif( type_element == room)then
     forall(e in index_set(elements))(
          forall(d in DAY)(
    cumulative(
      [x_slot[s]|s in room_sessions(elements[e])],
      [session_length(s)*bool2int( d == slot_day(x_slot[s])/\ (e in x_rooms[session_class(s)])  /\ slot_dayslot(x_slot[s]) in set_of_minmax )|s in room_sessions(elements[e])],
      [1 | s in room_sessions(elements[e])],
      day_slot_count
    )
  ))
    elseif( type_element == group)then
         forall(d in DAY)(
     forall(e in index_set(elements))(
    cumulative(
      [x_slot[s]|s in group_sessions(elements[e])],
      [session_length(s)*bool2int( d == slot_day(x_slot[s])/\/*(e in x_groups[session_class(s)])  /\*/ slot_dayslot(x_slot[s]) in set_of_minmax )|s in group_sessions(elements[e])],
      [1 | s in group_sessions(elements[e])],
      day_slot_count
    )
  ))
  
   elseif( type_element == session \/ type_element == course \/ type_element == part \/ type_element == class)then
     %forall(e in index_set(elements))(
          forall(d in DAY)(
    cumulative(
      [x_slot[sessions[s]]|s in index_set(sessions)],
      [session_length(sessions[s])*bool2int(d == slot_day(x_slot[s])/\ slot_dayslot(x_slot[sessions[s]]) in set_of_minmax )|s in index_set(sessions)],
      [1 | s in index_set(sessions)],
      day_slot_count
    ))
 else
 assert(false,"I dont understand type")
endif
;

/*via cumulative bool2int de la seance et bien apparient du prof concercé.
et apartient bien au creneau
n uplet ?
tester avec sum aussi pour voir
forall(teach puis sessiosn dans vecteur)()*/
% atMostDaily de 2 n-uplets de séances
predicate at_most_daily(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : weekly");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
true
;

% atMostDaily d'1 n-uplet de n-uplets alignés de séances
predicate at_most_daily(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_betatest,"U-contrainte : at most daily");
  int: a1 = my_trace(u_betatest,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
 true;
