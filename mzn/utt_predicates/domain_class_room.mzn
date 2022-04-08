%ROOM
%VALEUR DE ROOM POSSIBLE
predicate class_room_autorized()=
let{
   array[CLASS] of set of ROOM: class_room = [part_rooms[class_part(ci)]|ci in CLASS];
}
in forall(c in CLASS)(x_rooms[c] subset class_room[c])
;