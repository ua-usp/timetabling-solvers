%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RECIPROQUES DES CORRESPONDANCES DE CLASSES
%%
%% Toute correspondance surjective admet pour réciproque une fonction ayant pour domaine son co-domaine.
%% Toute correspondance non-surjective admet pour réciproque une multi-fonction ayant pour domaine son co-domaine.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RECIPROQUES DES CORRESPONDANCES UTT
%%
%% Les correspondances de composition (taxonomie du champ de formation) sont surjectives et leurs réciproques fonctionnnelles sont bien définies.
%% Les correspondances d'association (pré-allocation de ressources) ne sont pas nécessairement surjectives : on définit leurs réciproques par des multi-fonctions.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

include "tt_arrays.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RECIPROQUES DES CORRESPONDANCES SOURCES

% réciproque de `course_parts`
function COURSE: part_course(PART: p) = 
  min(c in COURSE where p in course_parts[c])(c);

% réciproque de `part_classes`
function PART: class_part(CLASS: c) =
  min(p in PART where c in part_classes[p])(p);
  
% réciproque de `part_rooms`
function set of PART: room_parts(ROOM: r) =
  {p | p in PART where r in part_rooms[p]};

% réciproque de `part_teachers`
function set of PART: teacher_parts(TEACHER: t) =
  {p | p in PART where t in part_teachers[p]};

% réciproque de `class_groups`
function set of CLASS: group_classes(GROUP: g) =
  {c | c in CLASS where g in class_groups[c]};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RECIPROQUES DES CORRESPONDANCES AUXILIAIRES

% fonction récursive renvoyant les séances d'un cours
% !! les cours sous-divisent la plage des séances en sous-plages consécutives
function set of SESSION: course_sessions(COURSE: c) =
  let {
    SESSIONS: s = sum(p in course_parts[c])(card(part_classes[p])*part_nr_sessions[p]); % nombre de séances du cours
  } in
  if c==1
  then 1..s % plage de séances du premier cours
  else max(course_sessions(c-1))+1..max(course_sessions(c-1))+s % plage de séances du c-ième cours
  endif;

% fonction récursive renvoyant les séances d'une partie
% !! les parties sous-divisent la plage des séances de leur cours en sous-plages consécutives
function set of SESSION: part_sessions(PART: p) =
  let {
    COURSE: c = part_course(p); % cours de la partie
    SESSIONS: s = card(part_classes[p])*part_nr_sessions[p]; % nombre de séances de la partie
    SESSIONS: n = sum(q in course_parts[c] where q<p)(card(part_classes[q])*part_nr_sessions[q]); % nombre de séances des parties jumelles précédentes
  } in
  if c==1
  then n+1..n+s
  else max(course_sessions(c-1))+n+1..max(course_sessions(c-1))+n+s
  endif;

% fonction récursive renvoyant les séances d'une classe
% !! les classes sous-divisent la plage des séances de leur partie en sous-plages consécutives
function set of SESSION: class_sessions(CLASS: c) =
  let {
    %int: a1 = trace("\n CLASS c = " ++ show(c),1);
    PART: p = class_part(c); % partie de la classe
    %int: a2 = trace("\n PART p = " ++ show(p),1);
    SESSIONS: s = part_nr_sessions[p]; % nombre de séances de la classe
    SESSIONS: n = sum(d in part_classes[p] where d<c)(part_nr_sessions[p]); % nombre de séances des classes précédentes de la partie
    %int: a3 = trace("\n SESSIONS s = " ++ show(s),1);
    %int: a4 = trace("\n SESSIONS n = " ++ show(n),1);
    
  } in
  if p==1
  then n+1..n+s
  else 
  max(part_sessions(p-1))+n+1..max(part_sessions(p-1))+n+s % plage de séances de la c-ième classe
  endif;

% renvoie les séances d'une salle, ie. l'union des ensembles de séances des parties requérant la salle
function set of SESSION: room_sessions(ROOM: r) =
  array_union([part_sessions(p) | p in room_parts(r)]);

% renvoie les séances d'un enseignant, ie. l'union des ensembles de séances des parties requérant l'enseignant
function set of SESSION: teacher_sessions(TEACHER: t) =
  array_union([part_sessions(p) | p in teacher_parts(t)]);

% renvoie les séances d'un groupe, ie. l'union des ensembles de séances des classes requérant le groupe
function set of SESSION: group_sessions(GROUP: g) =
  array_union([class_sessions(c) | c in group_classes(g)]);

% renvoie la classe d'une séance
function CLASS: session_class(SESSION: s) =
  min({c | c in CLASS where s in class_sessions(c)}); %TODO pas optimal

% renvoie la partie d'une séance
function int: session_part(SESSION: s)=
class_part(session_class(s));

% renvoie le rang d'une séance
function SESSION_RANK: session_rank(SESSION: s) = 
  s-min(class_sessions(session_class(s)))+1;

% renvoie la durée d'une séance
function int: session_length(SESSION:s)=
part_session_length[session_part(s)];

% ====== Slot function ==========
/*
% renvoie le jour d'un slot
function DAY: slot_day(SLOT: s)=
1+((s-1) div nr_slots_per_day);

% renvoie le jour dans la semaine d'un slot
function WEEKDAY: slot_weekday(SLOT: s)=
1+((slot_day(s)-1) mod nr_days_per_week);

% renvoie le creneau dans une journée du slot
function DAYSLOT: slot_dayslot(SLOT: s)=
1+((s-1) mod nr_slots_per_day);

% renvoie la semaine d'un slot
function WEEK: slot_week(SLOT: s)=
 1+((slot_day(s)-1) div nr_weeks);*/
 %=========
 % renvoie le jour d'un slot
function var DAY: slot_day(var SLOT: s)=
1+((s-1) div nr_slots_per_day);

% renvoie le jour dans la semaine d'un slot
function var WEEKDAY: slot_weekday(var SLOT: s)=
1+((slot_day(s)-1) mod nr_days_per_week);

% renvoie le creneau dans une journée du slot
function var DAYSLOT: slot_dayslot(var SLOT: s)=
1+((s-1) mod nr_slots_per_day);

% renvoie la semaine d'un slot
function var WEEK: slot_week(var SLOT: s)=
 1+((s-1) div nr_weekly_slots)
 %1+((slot_day(s)-1) div nr_weeks)
 ;
 
 % renvoie le slot dans une semaine
function var int: slot_weekslot(var SLOT: s)=
let{int :weekslot_duration = nr_slots_per_day * nr_days_per_week;} in
 1+((s-1) mod weekslot_duration);
 
 % renvoie la 

%==== search function
%renvoie le bon élément de padding 

function set of int: padding_value_with_name(string :s)=
let{
array[int] of int :tab_padding = [padding_value[i] | i in index_set(padding_name_value) where padding_name_value[i] == s];
}
in
array2set(tab_padding)
;
/*
function set of int: padding_set_with_name(string :s)=
let{
array[int] of int :tab_padding = [if(padding_name_value[i] == s)then padding_value[i] endif | i in index_set(padding_name_value)];
}
in
array2set(tab_padding)
;*/