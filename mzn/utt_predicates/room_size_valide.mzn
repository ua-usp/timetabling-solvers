%check size validity
function int: check_mandatory(PART : p)=
let { set of int : tmp_set = {-1} union {if p == part_room_mandatory[i,1] then part_room_mandatory[i,2] else -1 endif | i in index_set_1of2(part_room_mandatory)};} 
in max(tmp_set)
;
predicate room_capacity_validity() = 
let{
array[int] of int : mandatory_part = [check_mandatory(sub_p)|sub_p in PART];
}
in
forall(p in PART)(
  let{
  int: a6 = my_trace(u_lupredicate,"mandatory_part  ",mandatory_part);
  } in  
    forall(c in part_classes[p])(
    let{
      int :group_max_size = sum(g in class_groups[c])(group_headcount[g]);
      var int :room_max_size = sum(r in part_rooms[p])(bool2int(r in x_rooms[c])*room_capacity[r]);
    }
    in 
       room_max_size >= group_max_size  /\    if(mandatory_part[p] == -1) then
      true
    else
        {mandatory_part[p]} intersect x_rooms[c] != {}
    endif
    )
    
  )
;