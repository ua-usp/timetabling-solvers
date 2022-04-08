%% COUPLAGE SALLE POUR GROUPE ET SALLE POUR CLASSE
% (c-*-1) [dure] %TODO
%None overlaping constraint for room
predicate room_disjonctive()=
forall(r in ROOM)(
  if( card(room_sessions(r)) == 0  ) then
    true
  else 
    disjunctive(
      [x_slot[s]|s in room_sessions(r) ],
      [session_length(s)*bool2int(r in x_rooms[session_class(s)])|s in room_sessions(r)]
      %[bool2int(r in x_rooms[session_class(s)])*session_length(s)|s in room_sessions(r)]
    )
  endif
)
;