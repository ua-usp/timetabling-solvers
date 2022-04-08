%%%%%%%% NOT CONSECUTIVES ROOMS

function array[int] of int: parameters_particular_array(array[int] of int:tab,string:name)=
[tab[i]|i in index_set(tab) where parameter_name[tab[i]] == name ];

/*function set of int: label_rooms(int: label)=
array2set([if (label in room_label[r] )then r endif|r in room]) diff 0;*/

% notConsecutiveRooms d'1 n-uplet de séances
predicate not_consecutive_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : not_consecutive_rooms");
  int: a1 = my_trace(u_lupredicate,"1 tuple de séances",my_show("S",sessions,true));
  
  int: pmin = parameter_value[search_value_name(parameters,"minSlot"),1];
  int: pmax = parameter_value[search_value_name(parameters,"maxSlot"),1];
  array[int] of int: room = parameters_particular_array(parameters,"rooms");
  array[int] of int : room_label = [parameter_value[search_value_name(parameters,"rooms"),room[i]] | i in index_set(room)];
  set of int: time_range = pmin..pmax;
 % array[int] of SESSION : session_in_timerange = [if slot_dayslot(x_slot[sessions[i]]) in time_range then sessions[i] endif|i in index_set(sessions)];%séance de cours concercné par la plage horaire
  
  %jour concerné par la contrainte
  %set of int : day_range = array2set([slot_day(x_slot[session_in_timerange[i]]) | i in index_set(session_in_timerange)]) ;
  
  %array[int] of set of int : icmpatible_room_set= [ label_rooms(room_label[i]) |i in index_set(room_label)];
  
  } in
  true;
  
  
  
 /* 
  forall(d in day_range)(
    let{
    %session in time range and with the same day
      array[int] of SESSION : session_itr_d = [if slot_day(x_slot[session_in_timerange[i]]) == d then session_in_timerange[i] endif | i in index_set(session_in_timerange)];
      array[int] of set of ROOM: dsfsdfs =  [part_rooms[session_part(session_itr_d[i])] |i in index_set(session_itr_d)];
      }
      forall()()
      in true
  );*/
 /* forall(d in DAY)(
    let{
      array[int] of int : tab = [if x_slot[sessions[s]] in plage_horaire /\ slot_day(x_slot[sessions[s]]) == d then s endif|s in index_set(sessions)];
    }
    in
    exist(k in index_set(icmpatible_room_set))(
      forall(s in index_set(tab))(
        x_rooms[sessions[tab[s]]] 
        forall(ki in k..max(index_set(icmpatible_room_set)))(
          true
        )
      )
    )
  
  
  
    forall(s in index_set(sessions) where x_slot[sessions[s]] in plage_horaire /\ slot_day(x_slot[sessions[s]]) == d)(
      forall(s1 in s..max(index_set(sessions)))(
        let{
        set of int: [x_rooms[sessions[s] ]
        }
        in 
        true
      )
    )
  )
  
  /\
  
  forall(s in index_set(sessions) where slot_dayslot(x_slot[sessions[s]]) in plage_horaire )(
    let{
      int: smin = sessions[s]-1;
      int: smax = sessions[s]+1;
      %int: gggg = my_trace(u_betatest,"Not consecutives rooms:"++show(smin)++" "++show(smax)++" "++show(sessions[s]));
      int: s_ds = ((sessions[s]-1) mod 8) + 1;
      int: smin_ds = ((smin-1) mod 8) + 1;
      int: smax_ds = ((smax-1) mod 8) + 1;
      
     var set of int: label_s = array2set([ j| i in x_rooms[session_class(sessions[s])],j in room_label[i]]); 
    }
    in
    forall(k in index_set(room))(
      let{
        set of int: compare = array2set([parameter_value[room[k],l]|l in index_set_2of2(parameter_value)])diff{0};
      }
      in
      if((smin_ds < s_ds) /\ (smin>=1))then 
      let{
       var set of int: label_min = array2set([ j| i in x_rooms[session_class(smin)],j in room_label[i]]);
       var set of int: label_min_s=label_s intersect label_min;
      } 
      in if (card( compare intersect label_min_s ) > 1)then false else true endif endif /\
      if ((smax_ds > s_ds) /\ (smax<=nr_sessions))then
      let{
        %int: smaxdebug = my_trace(u_betatest,"SMAX DEBUG: "++show(smax));%++" "++show(session_class(smax)));
        var set of int: label_max = array2set([ j| i in x_rooms[session_class(smax)],j in room_label[i]]);
        var set of int: label_max_s=label_s intersect label_max;
      } 
      in  if (card( compare intersect label_max_s ) > 1)then false else true endif endif
    )
  )
;%FinPredicate
*/
% notConsecutiveRooms de 2 n-uplets de séances
predicate not_consecutive_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : not_consecutive_rooms");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
true
;

% notConsecutiveRooms d'1 n-uplet de n-uplets alignés de séances
predicate not_consecutive_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : not_consecutive_rooms");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
 true;
