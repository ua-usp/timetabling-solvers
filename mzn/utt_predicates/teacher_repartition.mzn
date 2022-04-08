%%%%%%%% TEACHER REPARTIITION
% TEACHER REPARTITION d'1 n-uplet de séances
%TODO VERIFICATION PARSER
predicate teacher_repartition(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : teacher_repartition");
  int: a1 = my_trace(u_lupredicate,"1 tuple de séances",my_show("S",sessions,true));
  int: part_to_repartition = session_part(sessions[0]);
  set of TEACHER: teachers = part_teachers[part_to_repartition]; 
  } in
true
;

% TEACHER REPARTITION de 2 n-uplets de séances
predicate teacher_repartition(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int] of SESSION: sessions1, array[int] of SESSION: sessions2, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : teacher_repartition");
  int: a1 = my_trace(u_lupredicate,"2 tuples de séances " ,my_show("S",sessions1,true) ++ " --  " ++ my_show("S",sessions2,true));
  } in
true
;
/*
% TEACHER REPARTITION d'1 n-uplet de n-uplets alignés de séances
predicate teacher_repartition(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : teacher_repartition");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  int: a3 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  
  array[int] of SESSION_V: sessions_one=[sessions[1,i] | i in index_set_2of2(sessions)];
  int: maxT = arg_min(sessions_one)-1;
  set of int: T = index_set_1of2(sessions);
  set of int: T2 = 1..maxT;
  array[int,int] of SESSION_V: sessions_not_padder =  array2d(T,T2,[sessions[i,j]| i in T, j in T2]);

  int: t = max(T);
  set of int: T1 = T diff {t};
  PART: p = session_part(sessions_not_padder[1,1]);
  array[int] of TEACHER: teachers_filter = [i|i in part_teachers[p]];
  array[int] of int: teachers_work = [part_teacher_sessions_count[i-1+p]|i in index_set(teachers_filter)];
  int: a2 = my_trace(u_betatest,"teachers_filter : ",teachers_filter);
  int: a2i = my_trace(u_betatest,"teachers_work : ",teachers_work);
  int: nr_sessions=maxT;
  } in
  forall(i in index_set(parameters))(
    if(parameter_value[parameters[i],1] == p_halfhalf) then
      forall(j in index_set_1of2(sessions_not_padder))(forall(k in 1..(nr_sessions div 2))(exists(l in index_set(teachers_filter))(x_teachers[sessions_not_padder[j,k]]=={teachers_filter[l]})))
      \/
       forall(j in index_set_1of2(sessions_not_padder))(forall(k in (nr_sessions div 2)..nr_sessions)(exists(l in index_set(teachers_filter))(x_teachers[sessions_not_padder[j,k]]=={teachers_filter[l]})))
    elseif (parameter_value[parameters[i],1] == p_single) then
      forall(j in index_set_1of2(sessions_not_padder))(forall(k in index_set_2of2(sessions_not_padder))(exists(l in index_set(teachers_filter))(x_teachers[sessions_not_padder[j,k]]=={teachers_filter[l]})))
    else trace("BUG: parameter is false",false) 
    endif
    )
    /\ 
    forall(u in index_set(teachers_work))(teachers_work[u] == sum(i in index_set_1of2(sessions_not_padder),j in index_set_2of2(sessions_not_padder))(bool2int(teachers_filter[u] in x_teachers[sessions_not_padder[i,j]] ))) 
 ;
 */
 % TEACHER REPARTITION d'1 n-uplet de n-uplets alignés de séances
predicate teacher_repartition(RULE: r, HARDNESS: h, ARITY: n, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: sessions, array[int] of PARAMETER: parameters) =
  let {
  int: a0 = my_trace(u_lupredicate,"U-contrainte : teacher_repartition");
  int: a1 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  int: a3 = my_trace(u_lupredicate,"empilement des tuples d'ensembles à multiplier",sessions);
  
  array[int] of SESSION_V: sessions_one=[sessions[1,i] | i in index_set_2of2(sessions)];
  int: maxT = arg_min(sessions_one)-1;
  set of int: T = index_set_1of2(sessions);
  set of int: T2 = 1..maxT;
  array[int,int] of SESSION_V: sessions_not_padder =  array2d(T,T2,[sessions[i,j]| i in T, j in T2]);
  

  int: t = max(T);
  set of int: T1 = T diff {t};
  PART: p = session_part(sessions_not_padder[1,1]);
  array[int] of TEACHER: teachers_filter = [i|i in part_teachers[p]];
  
  /*
 function set of PART_TEACHER : part_part_teachers(PART: p) = 
 if p==1
 then 1..card(part_teachers[p])
 else sum(i in 1..p-1)(card(part_teachers[i])+1..sum(i in 1..p-1)(card(part_teachers[i])+card(part_teachers[p])
 ;
  */
  
  array[int] of int: teachers_work = [part_teacher_sessions_count[1,i]|i in part_teachers[p]];
  %array[int] of int: teachers_work = [part_teacher_sessions_count[i]|i in part_part_teachers[p]];
  int: a2 = my_trace(u_betatest,"teachers_work : ",teachers_work);
  int: nr_sessions=maxT;
  } in
  forall(i in index_set(parameters))(
    
    if(parameter_value[parameters[i],1] == p_halfhalf) then
      let{
        int : k = nr_sessions div 2;
        int : nr_case = nr_sessions mod 2;
        int: a4 = my_trace(u_betatest,"teachers_work : ",teachers_work);
      }in
      % forall 1<=j<k  where k-j>1 : x_teachers[sessions_not_padder[i,j]==x_teachers[sessions_not_padder[i,k] -> x_teachers[sessions_not_padder[i,j+1]==x_teachers[sessions_not_padder[i,j]
        all_equal([x_teachers[sessions_not_padder[i,j]]|j in 1..k]) \/
        all_equal([x_teachers[sessions_not_padder[i,j]]|j in (k+1)..nr_sessions]) \/
      if(nr_case == 1)then 
        all_equal([x_teachers[sessions_not_padder[i,j]]|j in 1..k+1]) \/ all_equal([x_teachers[sessions_not_padder[i,j]]|j in (k+2)..nr_sessions])
      else 
         false
      endif
    
    elseif (parameter_value[parameters[i],1] == p_single) then
      all_equal([x_teachers[sessions_not_padder[i,j]]|j in 1..nr_sessions])
      
    elseif (parameter_value[parameters[i],1] == p_jumping_week)then 
      all_equal([x_teachers[sessions_not_padder[i,j]]|j in 1..nr_sessions where (j mod 2) ==1]) \/ all_equal([x_teachers[sessions_not_padder[i,j]]|j in 1..nr_sessions where (j mod 2) ==0])
    else trace("BUG: parameter is false",false) 
    endif
    )
    
    /\ 
  
    forall(u in index_set(teachers_work))(teachers_work[u] == sum(i in index_set_1of2(sessions_not_padder),j in index_set_2of2(sessions_not_padder))(bool2int(teachers_filter[u] in x_teachers[sessions_not_padder[i,j]] )))
 ;
