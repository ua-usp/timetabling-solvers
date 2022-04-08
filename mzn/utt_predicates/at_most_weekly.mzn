 predicate look_up_entities(ELEMENT : e,TYPE : typ,SLOT :s)=
 %equipment,room,teacher,group,courses,course,part,class,session
 if (typ == room)then
   e in x_rooms[x_slot[s]]
 elseif(typ == teacher)then
 e in x_teachers[x_slot[s]]
  elseif(typ == group)then
  e in class_groups[session_class(x_slot[s])]
    elseif(typ == course \/ typ == courses)then
      e == part_course(session_part( x_slot[s]))
    elseif(typ == part)then
      e == session_part(x_slot[s])
    elseif(typ == class)then
      e == session_part(x_slot[s])
    elseif(typ == equipment)then
      e == session_part(x_slot[s])
 else
e == x_slot[s]
 endif
 ;
 
 %%%%%%%% AT MOST WEEKLY
 %Maximum d'un événement toutes les semaines
% atMostWeekly d'1 n-uplet de séances
/*
predicate at_most_weekly(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_betatest,"U-contrainte : At most daily");
  int: a1 = my_trace(u_betatest,"1 tuple de séances",sessions);
    %int: a1 = my_trace(u_betatest,"1 tuple de séances",my_show("S",sessions,true));
  
  int:week_slot_count = parameter_value[search_value_name(parameters,"count"),1];
  
  } in
  %forall()
  forall(i in WEEK)(
    forall(j in index_set(elements))(
      sum(s in (1+nr_days_per_week*nr_slots_per_day*i)..(nr_days_per_week*nr_slots_per_day*(i+1)) where look_up_entities(elements[j],types[j],s))(
        1
      )<=week_slot_count
    )
  )
;*/

% atMostWeekly d'1 n-uplet de séances
predicate at_most_weekly(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_betatest,"U-contrainte : At most daily");
  int: a1 = my_trace(u_betatest,"1 tuple de séances",sessions);
    %int: a1 = my_trace(u_betatest,"1 tuple de séances",my_show("S",sessions,true));
  
  int:week_slot_count = parameter_value[search_value_name(parameters,"count"),1];
  
  } in
  if(types[1] == group)then 
     forall(e in index_set(elements))(
       forall(i in WEEK)(
        cumulative(
          [x_slot[s]|s in group_sessions(elements[e])],
          [session_length(s)*bool2int( i == slot_week(x_slot[s]) )|s in group_sessions(elements[e])],
          [1 | s in group_sessions(elements[e])],
          week_slot_count
        )
    )
  )
  elseif types[1] == teacher then 
       forall(e in index_set(elements))(
       forall(i in WEEK)(
        cumulative(
          [x_slot[s]|s in teacher_sessions(elements[e])],
          [session_length(s)*bool2int( e in x_teachers[session_class(s)] /\ i == slot_week(x_slot[s]) )|s in teacher_sessions(elements[e])],
          [1 | s in group_sessions(elements[e])],
          week_slot_count
        )
    )
  )
  
  elseif types[1] == room then 
       forall(e in index_set(elements))(
       forall(i in WEEK)(
        cumulative(
          [x_slot[s]|s in room_sessions(elements[e])],
          [session_length(s)*bool2int( e in x_teachers[session_class(s)] /\ i == slot_week(x_slot[s]) )|s in teacher_sessions(elements[e])],
          [1 | s in group_sessions(elements[e])],
          week_slot_count
        )
    )
  )  
  elseif types[1] == session \/ types[1] == course \/ types[1] == part \/ types[1] == class then 
       forall(i in WEEK)(
        cumulative(
          [x_slot[sessions[s]]|s in index_set(sessions)],
          [session_length(sesssions[s])*bool2int( i == slot_week(x_slot[sessions[s]]) )|s in index_set(sessions)],
          [1 | s in index_set(sessions)],
          week_slot_count
        )
    )   
  %
  else assert("probleme")
  endif
  ;

% atMostWeekly de 2 n-uplets de séances
predicate at_most_weekly(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : weekly");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
true
;

% atMostWeekly d'1 n-uplet de n-uplets alignés de séances
predicate at_most_weekly(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_betatest,"U-contrainte : at most weekly");
  int: a1 = my_trace(u_betatest,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
 true;