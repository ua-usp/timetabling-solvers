%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%
function string: my_show(string: key, int: value) = 
  %% Generic part
  if       key=="W"
  then "element type=" ++ type_name[to_enum(TYPE,value)]
  elseif key=="O"
  then "rank=" ++ show(value)
  elseif key=="CC"
  then "c-collector=" ++ show(value)
  elseif key=="SC"
  then "s-collector=" ++ show(value)
  elseif key=="M"
  then "" ++ show(value)
  elseif key=="f"
  then "filter=" ++ show(value)
  elseif key=="H"
  then "hardness=" ++ hardness_name[to_enum(HARDNESS,value)]
  elseif key=="A"
%  then if value>2 then "arity-type=" ++ utt_arity_type_name[to_enum(U_ARITY_TYPE,2)] else "arity-type=" ++ utt_arity_type_name[to_enum(U_ARITY_TYPE,value)]endif
  then "arity=" ++ show(value)
  elseif key=="V"
  then "parameter=" ++ show(value)
  %% TT-specific part
  elseif key=="E"
  then "equipment=" ++ equipment_name[value]
  elseif key=="R"
  then "room=" ++ room_name[value]
  elseif key=="T"
  then "teacher=" ++ teacher_name[value]
  elseif key=="G"
  then "group=" ++ group_name[value]
  elseif key=="U"
  then "" ++ course_name[value]
  elseif key=="P"
  then "" ++ course_name[part_course(value)] ++ "-"  ++ part_name[value]
  elseif key=="C"
  then "" ++ course_name[part_course(class_part(value))] ++ "-"  ++ part_name[class_part(value)] ++ "-"  ++ show(value)
  elseif key=="S"
  then "" ++ course_name[part_course(class_part(session_class(value)))] ++ "-"  ++ part_name[class_part(session_class(value))] ++ "-("  ++ show(value) ++  "," ++ show(session_rank(value)) ++ ")"
  elseif key=="F"
  then "constraint=" ++ constraint_name[to_enum(CONSTRAINT,value)]
  elseif key=="K"
  then "criterion=" ++ criterion_name[to_enum(CRITERION,value)]
  else trace("BUG: did not capture/implement expected name code","NAMING ERROR") 
  endif;
  
%
function string: my_show(string: t, array[int,int] of int: O, bool: start) =
  if start==true
  then  "<<" ++ my_show(t,O,false) ++ ">>"
  elseif card(index_set_1of2(O))==1
  then  my_show(t,O[min(index_set_1of2(O)),index_set_2of2(O)],true)
  else  my_show(t,O[min(index_set_1of2(O)),index_set_2of2(O)],true) ++ "," ++ my_show(t,O[index_set_1of2(O) diff {min(index_set_1of2(O))},index_set_2of2(O)],false)
  endif;

%  
function string: my_show(string: t, array[int] of int: O, bool: start) =
  if start==true
  then  "<" ++ my_show(t,O,false) ++ ">"
  elseif card(index_set(O))==1
  then  my_show(t,O[min(index_set(O))])
  else  my_show(t,O[min(index_set(O))]) ++ "," ++ my_show(t,O[index_set(O) diff {min(index_set(O))}],false)
  endif;
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%output[show(COST_RANGE)];
%output["session:"++show(session_rank(s))++";course:"++course_name[part_course(class_part(session_class(s)))]++";part:"++ part_name[class_part(session_class(s))]++";class:"++class_name[session_class(s)]++" weekly : "++show(x_slot[s])++" new_slot "++show(slot_day(x_slot[s]))++" week : "++show(slot_week(x_slot[s]))++" \n"| s in SESSION];%" slot duration "++ show(slot_dayslot(x_slot[s])) ++
output["session:"++show(session_rank(s))++";course:"++course_name[part_course(class_part(session_class(s)))]++";part:"++ part_name[class_part(session_class(s))]++";class:"++class_name[session_class(s)]++";teachers:"++ show([teacher_name[i]|i in fix(x_teachers[s])]) ++";rooms:"++show([room_name[i]|i in fix(x_rooms[session_class(s)])])++";group:"++show([group_name[i]|i in class_groups[session_class(s)]])++";slot:[\""++show(x_slot[s])++"\", \""++show(session_length(s))++"\"]\n"|s in SESSION]

%output["\n"]++[" Classe : "++course_name[part_course(class_part(c))]++" "++ part_name[class_part(c)]++" "++show(c)++" Prof :"++ show([teacher_name[i]|i in x_teachers[c]]) ++" ROOM : "++show([room_name[i]|i in x_rooms[c]])++" GROUP : "++show([group_name[i]|i in class_groups[c]])++"\n Creneau : "++show([x_slot[s]|s in class_sessions(c)])++"\n"|c in CLASS]