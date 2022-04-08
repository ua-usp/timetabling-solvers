%Teacher assignment

%% UTILISATION D'ENSEIGNANTS
% (c-t-1) [dure] Les sessions des classes placées affectée à un enseignant non-ubiquitaire doivent être séquencées en dehors des plages interdites pour l'enseignant.%TODO PLAGE INTERDITE
%None overlaping teacher

predicate teacher_disjonctive()=
forall(t in TEACHER  )(
  if( card(teacher_sessions(t)) == 0  ) then
    true
  else 
  disjunctive(
    [x_slot[s]         | s in teacher_sessions(t)], % [2,35,68]
    [session_length(s)*bool2int(t in x_teachers[s]) | s in teacher_sessions(t)]
    %[bool2int(t in x_teachers[session_class(s)])*session_length(s) | s in teacher_sessions(t)]%++Cas des forbidden slot
    )
    endif
)
;