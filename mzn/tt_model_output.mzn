%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

include "output.mzn";
include "tt_arrays.mzn";
include "./rules/rules_arrays.mzn";
include "./rules/rules_output.mzn";
include "tt_solution_output_extension.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

%
function bool: output_model() =
  let {
  int: A1 = my_output({u_json,u_json_mzn},"{");
  
  int: PAD0 = my_output({u_dzn,u_custom},"%PADDING");
  int: pad0 = my_output({u_json},"PADDING\" :");
  int: pad1 = my_output(U_OUTPUT_FORMAT,"{");
  int: pad2 = my_output(U_OUTPUT_FORMAT,"padding_value",padding_value,true);
  int: pad3 = my_output(U_OUTPUT_FORMAT,"padding_name_value",padding_name_value,true);
  int: pad4 = my_output(U_OUTPUT_FORMAT,"padding_set",padding_set,true);
  int: pad5 = my_output(U_OUTPUT_FORMAT,"padding_name_set",padding_name_set,u_output_format!=u_json);
  int: pad6 = my_output(U_OUTPUT_FORMAT,"},");

  int: B0 = my_output({u_json},"DATA\" :");
  int: B1 = my_output({u_json},"{");
  int: b1 = my_output({u_dzn,u_custom},"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
  int: b2 = my_output({u_dzn,u_custom},"% DATA");

  int: C1 = my_output({u_dzn,u_custom},"% TIME SCALES");
  int: c1 = my_output(U_OUTPUT_FORMAT,"nr_weeks",nr_weeks,true);
  int: c2 = my_output(U_OUTPUT_FORMAT,"nr_days_per_week",nr_days_per_week,true);
  int: c3 = my_output(U_OUTPUT_FORMAT,"nr_slots_per_day",nr_slots_per_day,true);

  int: D1 = my_output({u_dzn,u_custom},"% COURSES");
  int: d1 = my_output(U_OUTPUT_FORMAT,"nr_courses",nr_courses,true);
  int: d2 = my_output(U_OUTPUT_FORMAT,"nr_parts",nr_parts,true);
  int: d3 = my_output(U_OUTPUT_FORMAT,"course_parts",course_parts,true);
  int: d4 = my_output(U_OUTPUT_FORMAT,"nr_classes",nr_classes,true);
  int: d5 = my_output(U_OUTPUT_FORMAT,"part_classes",part_classes,true);
  int: d6 = my_output(U_OUTPUT_FORMAT,"nr_sessions",nr_sessions,true);
  int: d7 = my_output(U_OUTPUT_FORMAT,"max_part_sessions",max_part_sessions,true);
  int: d8 = my_output(U_OUTPUT_FORMAT,"part_nr_sessions",part_nr_sessions,true);
  
  int: E1 = my_output({u_dzn,u_custom},"% RESOURCES");
  int: e1 = my_output(U_OUTPUT_FORMAT,"nr_equipments",nr_equipments,true);
  int: e2 = my_output(U_OUTPUT_FORMAT,"nr_rooms",nr_rooms,true);
  int: e3 = my_output(U_OUTPUT_FORMAT,"nr_teachers",nr_teachers,true);
  int: e4 = my_output(U_OUTPUT_FORMAT,"nr_groups",nr_groups,true);

  int: F1 = my_output({u_dzn,u_custom},"% COURSE-RESOURCE MAPS");
  int: f1 = my_output(U_OUTPUT_FORMAT,"nr_part_rooms",nr_part_rooms,true);
  int: f2 = my_output(U_OUTPUT_FORMAT,"part_rooms",part_rooms,true);
  int: f3 = my_output(U_OUTPUT_FORMAT,"nr_part_teachers",nr_part_teachers,true);
  int: f4 = my_output(U_OUTPUT_FORMAT,"part_teachers",part_teachers,true);
  int: f5 = my_output(U_OUTPUT_FORMAT,"part_dailyslots",part_dailyslots,true);
  int: f6 = my_output(U_OUTPUT_FORMAT,"part_days",part_days,true);
  int: f7 = my_output(U_OUTPUT_FORMAT,"part_weeks",part_weeks,true);
  int: f8 = my_output(U_OUTPUT_FORMAT,"class_groups",class_groups,true);

  int: G1 = my_output({u_dzn,u_custom},"% COURSE PROPERTIES");
  int: g1 = my_output(U_OUTPUT_FORMAT,"part_session_length",part_session_length,true);
  
  int: H1 = my_output({u_dzn,u_custom},"% RESOURCE PROPERTIES");
  int: h1 = my_output(U_OUTPUT_FORMAT,"max_equipment_count",max_equipment_count,true); 
  int: h2 = my_output(U_OUTPUT_FORMAT,"max_class_maxheadcount",max_class_maxheadcount,true); 
  int: h3 = my_output(U_OUTPUT_FORMAT,"max_teacher_session",max_teacher_session,true); 
  int: h4 = my_output(U_OUTPUT_FORMAT,"max_teacher_sessions",max_teacher_sessions,true); 
  int: h5 = my_output(U_OUTPUT_FORMAT,"equipment_count",equipment_count,true);
  int: h6 = my_output(U_OUTPUT_FORMAT,"max_room_capacity",max_room_capacity,true); 
  int: h7 = my_output(U_OUTPUT_FORMAT,"room_capacity",room_capacity,true);
  
  int: I1 = my_output({u_dzn,u_custom},"% COURSE-RESOURCE PROPERTIES");
  int: i1 = my_output(U_OUTPUT_FORMAT,"part_room_use",part_room_use,utt_resource_use_name,true);
  int: i2 = my_output(U_OUTPUT_FORMAT,"nr_part_room_mandatory",nr_part_room_mandatory,true); % TODO remove?
  int: i3 = my_output(U_OUTPUT_FORMAT,"part_room_mandatory",part_room_mandatory,true); % TODO no array2d
%  int: i3 = my_output(U_OUTPUT_FORMAT,"part_room_mandatory","1..nr_part_room_mandatory","1..2",part_room_mandatory,true); % TODO no array2d
  int: i4 = my_output(U_OUTPUT_FORMAT,"part_teacher_sessions_count",part_teacher_sessions_count,true);
  int: i5 = my_output(U_OUTPUT_FORMAT,"part_session_teacher_count",part_session_teacher_count,true);
  int: i6 = my_output(U_OUTPUT_FORMAT,"class_maxheadcount",class_maxheadcount,true);
  int: i7 = my_output(U_OUTPUT_FORMAT,"class_parent",class_parent,true);
  
  int: STUD0 = my_output({u_dzn,u_custom},"% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
  int: STUD1 = my_output({u_dzn,u_custom},"% STUDENTS");
  int: stud0 = my_output(U_OUTPUT_FORMAT,"student_courses",student_courses,true);

  int: J0 = my_output({u_dzn,u_custom},"% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
  int: J1 = my_output({u_dzn,u_custom},"% NAMINGS");
  int: j1 = my_output(U_OUTPUT_FORMAT,"equipment_name",equipment_name,true);
  int: j2 = my_output(U_OUTPUT_FORMAT,"room_name",room_name,true);
  int: j3 = my_output(U_OUTPUT_FORMAT,"teacher_name",teacher_name,true);
  int: j4 = my_output(U_OUTPUT_FORMAT,"student_name",student_name,true);
  int: j5 = my_output(U_OUTPUT_FORMAT,"course_name",course_name,true);
  int: j6 = my_output(U_OUTPUT_FORMAT,"part_name",part_name,true);
  int: j7 = my_output(U_OUTPUT_FORMAT,"class_name",class_name,true);

  int: K1 = my_output({u_dzn,u_custom},"% LABELINGS"); % american english form
  int: k1 = my_output(U_OUTPUT_FORMAT,"nr_labels",nr_labels,true); % TODO remove?
  int: k2 = my_output(U_OUTPUT_FORMAT,"label_name",label_name,true);
  %TODO ?? no equipment labels ?
  int: k4 = my_output(U_OUTPUT_FORMAT,"room_label",room_label,true);
  int: k5 = my_output(U_OUTPUT_FORMAT,"teacher_label",teacher_label,true);
  int: k6 = my_output(U_OUTPUT_FORMAT,"student_label",student_label,true);
  int: k7 = my_output(U_OUTPUT_FORMAT,"course_label",course_label,true);
  int: k8 = my_output(U_OUTPUT_FORMAT,"part_label",part_label,u_output_format!=u_json);
  %TODO ?? no class labels ?
  int: B2 = my_output({u_json},"},");
  } in
 true;
 
 
%
constraint
  output_model() /\ output_rules_model() /\ output_solution_extension();
 