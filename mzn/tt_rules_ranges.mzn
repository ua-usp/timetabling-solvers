%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CATEGORIES, CLASSES ET DIMENSIONS

include "tt_rules_bounds.mzn";
include "tt_ranges.mzn";
include "./rules/rules_ranges.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CATEGORIES

% les contraintes UTT
%TODO ITC contraintes : same_start, same_time, same_days, same_weeks, same_room, different_time, different_days, different_weeks, different_room, overlap, same_attendees, precedence, work_day, min_gap, not_overlap, max_days, max_day_load, max_breaks, max_block};
CONSTRAINT = {allocate_slot,at_most_daily,connected_rooms,forbidden_slots,not_consecutive_rooms,same_rooms,same_slots,same_teachers,same_week,sequenced,teacher_repartition,weekly};
constraint_name = ["allocate_slot","at_most_daily","connected_rooms","forbidden_slots","not_consecutive_rooms","same_rooms","same_slots","same_teachers","same_week","sequenced","teacher_repartition","weekly"];

% les critères UTT
CRITERION = {k_time,k_equipment,k_room,k_teacher,k_group}; % TODO les critères de UTT-coût
criterion_name = ["time","equipment","room","teacher","group"];

% domaine de paramètre pour une contrainte UTT
enum  UTT_PARAMETER_VALUE = {p_single,p_halfhalf,p_jumping_week};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CLASSES

% classes cibles
TYPE = {equipment,room,teacher,group,courses,course,part,class,session};
type_name = ["equipment","room","teacher","group","courses","course","part","class","session"];

% les éléments cibles
%% NB. L'ensemble des identifiants d'éléments cibles est défini comme l'union des ensembles d'identifiants d'éléments typés (salles, classes, ...).
%% NB. Il est inutile, pour l'usage qui est en est fait, de définir cet ensemble comme une partition des ensembles d'identifiants typés.
%% NB. Les domaines COURSE, PART, CLASS sont redondants puisque nécessairement inclus dans SESSION.
%% NB. Le type singleton COURSES nétant pas défini est omis.
ELEMENT = 1..max(array_union([EQUIPMENT,ROOM,TEACHER,GROUP,COURSE,PART,CLASS,SESSION]));

% les quarks
QUARK = SESSION;

% les quarks
QRANK = SESSION_RANK;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DIMENSIONS

% arité de contrainte
ARITY = 1..10;

% valeur de paramètre
PARAMETER_VALUE = -1000000..100000 union UTT_PARAMETER_VALUE;%TODO ideally min(int)+1..max(int)
