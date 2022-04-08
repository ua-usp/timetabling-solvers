
%%%%%%%% CONNECTED_ROOMS
% connectedRooms d'1 n-uplet de séances
predicate connected_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : connected_rooms");
  int: a1 = my_trace(u_lupredicate,"1 tuple de séances",my_show("S",sessions,true));
  set of int: class_of_constraint = array2set([session_class(sessions[i]) |i in index_set(sessions)]);
  
  } in
  /*
    Existe une chaine ok pour une séance : var "chain" : la bonne chaine
    x_rooms[s] subset array2set(Chain)
    var s_min[s] = argmin(i in INDEX_CHAIN)(Chain[i] in x_rooms[s])
    var s_max[s] = argmax(i in INDEX_CHAIN)(Chain[i] in x_rooms[s])
    s_max[s] - s_min[s] + 1 = card(x_rooms[s])
    PLUS : même chaine pour toutes les séances
    PLUS : max(s in sessions)(s_max[s]) - min(s in sessions)(s_min[s]) + 1 = sum(s in sessions)(card(x_rooms[s])
    
    Cas où 1 salle par séance
    sessions => R = [ min(x_rooms[s]) | s in sessions]
    Cas où 1 seule chaine de salles déclarée en paramètre Chain = [ salle_i | i in INDEX_CHAIN]
            [ y[i] | i in index_set[R]] y[i] in INDEX_CHAIN
    forall s in sessions
      R[s] = Chain[y[s]]
    max(y)-min(y)+1=card(sessions)
    
  */
  forall(i in class_of_constraint)(
    let{
      %array[int] of var int: room_ordonnate=find_correct_room_list(i,parameters);
      int: a2 = my_trace(u_betatest,"yo je suis les parameters",show(parameters));
    }
    in 
    %true \/
    exists(j in index_set(parameters))(
      let{
        array[int] of int : room_chain = [parameter_value[parameters[j],k] | k in index_set_2of2(parameter_value)];
        set of int : set_room_chain = array2set(room_chain);
        int: a = my_trace(u_betatest,"yo je suis le bug",show(set_room_chain));
      }
      in x_rooms[i] subset set_room_chain diff {0}
      
      /\
      forall(k in x_rooms[i])(
        exists(ki in index_set(room_chain) where room_chain[ki]==k)(
          if(ki == max_parameter_size) then 
          true
          else
          room_chain[ki+1] in x_rooms[i]
          endif            
        )

      )
    )
    
    
  )
;

% connectedRooms de 2 n-uplets de séances
predicate connected_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : connected_rooms");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
true
;

% connectedRooms d'1 n-uplet de n-uplets alignés de séances
predicate connected_rooms(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : connected_rooms");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  set of int: T = index_set_1of2(sessions);
  int: t = max(T);
  set of int: T1 = T diff {t};
  } in
 true;
