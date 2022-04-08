%read data domain of part

predicate teacher_sessions_count() = 

forall(p in PART)(
  forall(t in part_teachers[p])( 
  let{
  int: a4 = my_trace(u_lupredicate,"nrSessionsPerTeacher ",part_teacher_sessions_count[p,t]);
  int: a5 = my_trace(u_lupredicate,"Teacher  ",teacher_name[t]);
  int: a6 = my_trace(u_lupredicate,"part  ",part_name[p]);
  
  } in 
    sum(s in part_sessions(p))(bool2int(t in x_teachers[s])) == part_teacher_sessions_count[p,t]
  )
)
;