%GROUPE
%TODO constraint verfication groups
%Groupe autorisé dans une classe, séparation propre
% un group ne peut avoir qu'une seul seance par creneau
predicate group_disjonctive()=
forall(g in GROUP)(
  disjunctive(
    [x_slot[s]                |s in group_sessions(g)],
    [session_length(s)        |s in group_sessions(g)]
  )
)
;