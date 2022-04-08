
%VALEUR DE TEACHER POSSIBLE
predicate teacher_consomation()=
forall(s in SESSION)(
%let{int: gggg = my_trace(u_lupredicate,"teacher_Consomation:"++" "++show(part_teachers[session_part(s)]));} in
  x_teachers[s] subset part_teachers[session_part(s)] \/ x_teachers[s] == {} 
)
;
