%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

%
function bool: output_solution_extension() =
  let {
  int: SOL0 = my_output({u_dzn,u_custom},"%SOLUTION");
  int: SOL1 = my_output({u_json},"SOLUTION\" :");
  int: SOL2 = my_output({u_json},"{");
  
  int: GROUP0 = my_output({u_json},"GROUPES\" :");
  int: GROUP1 = my_output({u_json},"{");
  int: group1 = my_output(U_OUTPUT_FORMAT,"nr_groups",nr_groups,true);
  int: group2 = my_output(U_OUTPUT_FORMAT,"max_group_headcount",max_group_headcount,true);
  int: group3 = my_output(U_OUTPUT_FORMAT,"group_headcount",group_headcount,true);
  int: group4 = my_output(U_OUTPUT_FORMAT,"group_name",group_name,true);
  int: group5 = my_output(U_OUTPUT_FORMAT,"group_students",group_students,u_output_format!=u_json);
  int: GROUP_fin = my_output({u_json},"},");
  
  int: CLASS0 = my_output({u_json},"CLASSES\" :");
  int: CLASS1 = my_output({u_json},"{");
  int: class1 = my_output(U_OUTPUT_FORMAT,"class_teachers",class_teachers,true);
  int: class2 = my_output(U_OUTPUT_FORMAT,"class_rooms",class_rooms,true);
  int: class3 = my_output(U_OUTPUT_FORMAT,"class_groups",class_groups,u_output_format!=u_json);
  int: CLASS_fin = my_output({u_json},"},");
  
  int: SESSIONS0 = my_output({u_json},"SESSIONS\" :");
  int: SESSIONS1 = my_output({u_json},"{");
  int: sessions1 = my_output(U_OUTPUT_FORMAT,"session_dailyslot",session_dailyslot,true);
  int: sessions2 = my_output(U_OUTPUT_FORMAT,"session_day",session_day,true);
  int: sessions3 = my_output(U_OUTPUT_FORMAT,"session_week",session_week,true);
  int: sessions4 = my_output(U_OUTPUT_FORMAT,"session_rooms",session_rooms,true);
  int: sessions5 = my_output(U_OUTPUT_FORMAT,"session_teachers",session_teachers,u_output_format!=u_json); 
  int: SESSIONS_fin = my_output({u_json},"}");
  
  
  int: SOL_fin = my_output({u_json},"},");

  } in
 true;
 