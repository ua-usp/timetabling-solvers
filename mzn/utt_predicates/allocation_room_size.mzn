%% ALLOCATION DE SALLES (CLASSES SANS SALLES, MONO-SALLE, OU MULTI-SALLES)
% (c-r-1) [dure] Une classe doit être placée dans un nombre de salles conforme à son type.
% Ajustement du nombre de salle
predicate allocation_room_size()=
forall(c in CLASS)(
  ((part_room_use[class_part(c)]==none) <-> (x_rooms[c] == {}))
  /\
  ((part_room_use[class_part(c)]==single) -> (card(x_rooms[c]) == 1))
  /\
  ((part_room_use[class_part(c)]==multiple) -> (card(x_rooms[c])>=1))
)
;
