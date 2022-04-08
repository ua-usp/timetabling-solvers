%GROUP
%VALEUR DE GROUP POSSIBLE
predicate class_group_autorized()=
let{
   array[CLASS] of set of ROOM: class_room = [part_rooms[class_part(ci)]|ci in CLASS];
}
in forall(c in CLASS)(x_rooms[c] subset class_room[c])
;