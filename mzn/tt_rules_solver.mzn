%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPLEMENTATION DE L'API DU GENERATEUR DE CONTRAINTES POUR PROBLEME EDT


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INCLUSIONS DES FICHIERS DU GENERATEUR

include "./rules/rules_solver_api.mzn";
include "output.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROPRIETES ET CORRESPONDANCES DE CLASSES

% renvoie l'ensemble d'éléments de la classe `t`
function set of ELEMENT: elements(TYPE: t) =
  if       t==equipment then EQUIPMENT
  elseif t==room then ROOM
  elseif t==teacher then TEACHER
  elseif t==group then GROUP
  elseif t==courses then 1..1 % !! plage non réifiée (racine de la hiérarchie)
  elseif t==course then COURSE
  elseif t==part then PART
  elseif t==class then CLASS
  else SESSION
  endif;
  
% renvoie les séances d'un élément selon son identifiant et son type
%% renvoie la séance en entrée (singleton) si le type est `session`
%% renvoie la plage des séances si le type est `courses`
function set of QUARK: element_quarks(TYPE: t, ELEMENT: e) =
  if       t==room then room_sessions(e)
  elseif t==teacher then teacher_sessions(e)
  elseif t==group then group_sessions(e)
  elseif t==courses then SESSION % plage des séances
  elseif t==course then course_sessions(e)
  elseif t==part then part_sessions(e)
  elseif t==class then class_sessions(e)
  else {e}
  endif;

% renvoie le rang du quark `q`
function QRANK: quark_rank(QUARK: q) =
  session_rank(q);
  
% arité des UTT-contraintes
constraint_arities = [
{arity_1,arity_n}, %same_rooms
{arity_1,arity_n}, %same_slots
{arity_1,arity_n}, %same_teachers
{arity_1,arity_n}, %same_week
{arity_1,arity_n}, %sequenced
{arity_1,arity_n}, %weekly
{arity_1,arity_n}, %repartitionteacher
{arity_1,arity_n}, %forbiddenSlots
{arity_1,arity_n}, %not_consecutive_rooms
{arity_1,arity_n}, %connected_rooms
{arity_1,arity_n}, %at_most_daily
{arity_1,arity_n}  %allocate_slot
];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PREDICAT GENERATIF

%% Pose de U-contrainte
predicate r_constraint(RULE: r, CONSTRAINT: c, HARDNESS: h, ARITY: a, array[int] of TYPE: types, array[int] of ELEMENT: elements, array[int,SESSION] of SESSION_V: session_tuples, array[int] of PARAMETER: parameters) =
  %%% Generic part (leave as is)
  let {
  int: a0 = my_trace(u_luconstraint,"POSE DE CONTRAINTE");
  bool: checkarg1 = assert(a==card(index_set(types)),"inconsistent arity and number of types " ++ show(types),true);
  bool: checkarg2 = assert(a==card(index_set(elements)),"inconsistent arity and number of elements " ++ show(elements),true);
  bool: checkarg3 = assert(a==card(index_set_1of2(session_tuples)),"inconsistent arity and number of session tuples " ++ show(session_tuples),true);
  set of int: Q = index_set_1of2(session_tuples);
  int: q1 = min(Q);
  set of int: Q2 = Q diff {q1};
  array[int] of QUARK_V: qquark1 = unpad_tuple(array_2d_to_1d(session_tuples[q1..q1,QUPLE]),qquark_padder); %TODO unpad_quple(session_tuples[q1..q1,QUPLE]);
  % trace
  string: s0 = show(r);
  string: s1 = constraint_name[to_enum(CONSTRAINT,c)];
  string: s2 = hardness_name[to_enum(HARDNESS,h)];
  string: s3 = show(a);
  string: s4 = "[" ++ join(",",[type_name[to_enum(TYPE,types[i])] | i in index_set(types)]) ++ "]";
  string: s5 = "[" ++ join(",",[show(elements[i]) | i in index_set(elements)]) ++ "]";
  string: s6 =  if a==1 then quote(qquark1) else quote(session_tuples) endif ;
%  if a==1 then "[" else "[|"  endif ++ join("|",[join(",",[show(session_tuples[i,j]) | j in QUPLE]) | i in index_set_1of2(session_tuples)]) ++ if a==1 then "]" else "|]"  endif ;
  string: s7 = "[" ++ join(",",[show(parameters[i]) | i in index_set(parameters)]) ++ "]";  
  int: a01 = my_trace(u_luconstraint,"Rule     : " ++ s0);
  int: a1 = my_trace(u_luconstraint,"Constraint     : " ++ s1);
  int: a2 = my_trace(u_luconstraint,"Hardness    : " ++ s2);
  int: a3 = my_trace(u_luconstraint,"Arity            : " ++ s3);
  int: a4 = my_trace(u_luconstraint,"Sorts          : " ++ s4);
  int: a5 = my_trace(u_luconstraint,"Bindings     : " ++ s5);
  int: a6 = my_trace(u_luconstraint,"Q-quarks   : " ++ s6);
  int: a7 = my_trace(u_luconstraint,"Parameters : " ++ s7);  
  int: a8 = my_trace(u_luconstraint,"constraint " ++ s1++"("++join(",",[s0,s2,s3,s4,s5,s6,s7])++");");
  % output
  int: B1 = my_output({u_dzn,u_custom},"constraint " ++ s1++"("++join(",",[s0,s2,s3,s4,s5,s6,s7])++");");
%  int: A0 = my_output({u_json},"constraint\" : ");
  int: A01 = my_output({u_json},"{");
  int: A1 = my_output({u_json},"rule",r,true);
  int: A2 = my_output({u_json},"constraint",c,constraint_name,true);
  int: A3 = my_output({u_json},"hardness",h,hardness_name,true);
  int: A4 = my_output({u_json},"arity",a,true);
  int: A5 = my_output({u_json},"types",types,type_name,true);
  int: A6 = my_output({u_json},"elements",elements,true);
  int: A7 = my_output({u_json},"t-sessions",session_tuples,true);
  int: A8 = my_output({u_json},"parameters",parameters,false);
  int: A9 = my_output({u_json},"}");
  } in
  if u_output_cut == u_cut then true 
  else
  %%% Specific part
  %% arity 1
  if       a==arity_1 /\ c==allocate_slot
  then  allocate_slot(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==at_most_daily
  then  at_most_daily(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==connected_rooms
  then  connected_rooms(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==forbidden_slots
  then  forbidden_slots(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==not_consecutive_rooms
  then  not_consecutive_rooms(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==same_rooms
  then  same_rooms(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==same_slots
  then  same_slots(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==same_teachers
  then  same_teachers(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==same_week
  then  same_week(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==sequenced
  then  sequenced(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==teacher_repartition
  then  teacher_repartition(r,h,a,types,elements,qquark1,parameters)
  elseif a==arity_1 /\ c==weekly
  then  weekly(r,h,a,types,elements,qquark1,parameters)

  %% arity > 1 
  elseif c==allocate_slot
  then  allocate_slot(r,h,a,types,elements,session_tuples,parameters)
  elseif c==at_most_daily
  then  at_most_daily(r,h,a,types,elements,session_tuples,parameters)
  elseif c==connected_rooms
  then  connected_rooms(r,h,a,types,elements,session_tuples,parameters)
  elseif c==forbidden_slots
  then  forbidden_slots(r,h,a,types,elements,session_tuples,parameters)
  elseif c==not_consecutive_rooms
  then  not_consecutive_rooms(r,h,a,types,elements,session_tuples,parameters)
  elseif c==same_rooms
  then  same_rooms(r,h,a,types,elements,session_tuples,parameters)
  elseif c==same_slots
  then  same_slots(r,h,a,types,elements,session_tuples,parameters)
  elseif c==same_teachers
  then  same_teachers(r,h,a,types,elements,session_tuples,parameters)
  elseif c==same_week
  then  same_week(r,h,a,types,elements,session_tuples,parameters)
  elseif c==sequenced
  then  sequenced(r,h,a,types,elements,session_tuples,parameters)
  elseif c==teacher_repartition
  then  teacher_repartition(r,h,a,types,elements,session_tuples,parameters)
  elseif c==weekly
  then  weekly(r,h,a,types,elements,session_tuples,parameters)
  else trace("BUG: did not capture/implement expected U-function name",false) 
  endif
  endif
  ;
