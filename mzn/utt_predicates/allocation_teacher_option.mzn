

%% ALLOCATION DES ENSEIGNANTS (CLASSES SANS PROF, MONO-PROF, OU MULTI-PROF)
% (c-r-1) [dure] Une classe doit être placée avec un nombre d'enseignats conforme à son type.
predicate allocation_teacher_option()=
forall(s in SESSION)(
card(x_teachers[s]) == part_session_teacher_count[session_part(s)]
);
