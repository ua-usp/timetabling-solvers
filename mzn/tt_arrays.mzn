%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROPRIETES ET CORRESPONDANCES DE CLASSES
%%
%% Propriétés et correspondances de classes sont des fonctions dont le domaine est une classe et qui peuvent être mono-valuées ou multi-valuées (ie. des multi-fonctions), partielles ou totales.
%% Une propriété de classe a pour co-domaine une dimension dite *dimension cible*.
%% Une correspondance de classe a pour co-domaine une classe dite *classe cible* .
%%  
%% Propriétés et correspondances de classes se définissent individuellement par un tableau MZN dont l'ensemble d'indexation est le domaine de la fonction associée (ie. la plage de la classe de départ).
%%
%% Le tableau MZN d'une propriété (respectivement, correspondance) est à valeurs dans :
%% - la dimension cible (resp., classe cible) si la propriété (resp. correspondance) est mono-valuée et totale,
%% - la dimension cible virtualisée (resp. classe cible virtualisée) si la propriété (resp. correspondance) est mono-valuée et partielle,
%% - l'ensemble des parties de la dimension cible (resp., de la classe cible) si la propriété (resp. correspondance) est multi-valuée et totale,
%% - l'ensemble des parties de la dimension cible virtualisée (resp. classe) cible virtualisée si la propriété (resp. correspondance) est multi-valuée et partielle.
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LES CORRESPONDANCES ENTRE UTT-ELEMENTS
%%
%% Une instance UTT définit différentes correspondances entre classes d'UTT-éléments : 
%% - le champ de formations se compose de cours (partition)
%% - chaque cours se compose de parties (partition)
%% - chaque partie se compose de classes (partition)
%% - chaque partie est associée à un ensemble, potentiellement vide, de salles allouables à ses classes
%% - chaque partie est associée à un ensemble, potentiellement vide, d'enseignants allouables à ses séances
%% - chaque classe se compose de séances (partition)
%% - chaque classe est associée à un ensemble non vide de groupes alloués à ses séances.
%%
%% Ces correspondances sont des multi-fonctions totales.
%%
% NUMEROTATION DE SEANCES
%% Cours, parties, classes et séances sont identifiés par des numéros (entiers) sur des plages normées (démarrant à 1)
%%.
%% Le schéma de numérotation suit l'organisation hiérarchique du champ de formations :
%% - les parties d'un cours forment une plage et les plages des parties de deux cours consécutifs sont consécutives
%% - les classes d'une partie forment une plage et les plages des classes de deux parties consécutives sont consécutives
%% - les séances d'une classe forment une plage et les plages des séances de deux classes consécutives sont consécutives.
%%
% RANG DE SEANCES
%% Le *rang d'une séance* désigne le rang de son numéro dans la plage des séances de sa classe (rang 1 par convention pour la première séance).
%%
%% Les rangs de séances sur l'ensemble des classes forment une plage d'entiers notée `SESSION_RANK`.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


include "tt_ranges.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CORRESPONDANCES DE CLASSES : COMPOSITION ET ASSOCIATION
array[COURSE] of set of PART: course_parts; % les parties d'un cours
array[PART] of set of CLASS: part_classes; % les classes d'une partie
array[PART] of set of ROOM: part_rooms; % les salles possibles d'une partie
array[PART] of set of TEACHER: part_teachers; % les enseignants d'une partie
%array[CLASS] of set of GROUP: class_groups; % les groupes d'une classe
array[PART] of set of DAYSLOT: part_dailyslots; % les dailys slots possibles pour une partie
array[PART] of set of DAY: part_days; % les jours d'une semaines possibles pour une partie
array[PART] of set of WEEK:part_weeks; % les weeks possibles pour une partie

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROPRIETES DE CLASSES : DIMENSIONNEMENT ET MODALITES D'ALLOCATION DE RESSOURCES
array[EQUIPMENT] of E_COUNT_V: equipment_count; % le décompte d'équipements par type d'équipement (!!! potentiellement illimité)
array[ROOM] of R_CAPACITY_V: room_capacity; % la capacité d'une salle (!!! potentiellement illimitée)
array[GROUP] of G_HEADCOUNT_V: group_headcount; % la taille d'un groupe %TODO move ?
array[PART] of SESSIONS: part_nr_sessions; % le nombre de séances de chaque classe d'une partie
array[PART] of SLOTS: part_session_length; % la durée des séances d'une partie
array[PART] of UTT_RESOURCE_USE: part_room_use; % la politique d'allocation de salles par séance d'une partie
array[PART_ROOM_MANDATORY,1..2] of int: part_room_mandatory; % l'obligation d'allouer une salle à au moins une classe d'une partie
%array[PART] of 0..max_part_teachers: part_teacher_count; % le nombre d'enseignants par partie
array[PART,TEACHER] of T_SESSIONS: part_teacher_sessions_count; % le nombre de séances à attribuer à un enseignant d'une partie
%array[PART_TEACHER] of T_SESSIONS: part_teacher_sessions_count; % le nombre de séances à attribuer à un enseignant d'une partie
array[PART] of T_COUNT: part_session_teacher_count; % le nombre de teacher par session pour une part
array[STUDENT] of set of COURSE: student_courses; % les cours dans lesquels sont incrits les étudiants
array[CLASS] of C_PARENT: class_parent; % parenté entre les classes
array[CLASS] of C_MAXHEADCOUNT: class_maxheadcount; % effectif maximum de chaque class

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROPRIETES DE CLASSES : DENOMINATION
array[EQUIPMENT] of string: equipment_name; % le nom d'un équipement
array[ROOM] of string: room_name; % le nom d'une salle
array[TEACHER] of string: teacher_name; % le nom d'un enseignant
array[GROUP] of string: group_name; % le nom d'un groupe
array[COURSE] of string: course_name; % le nom d'un cours
array[PART] of string: part_name; % le nom d'une partie
array[CLASS] of string: class_name;%le nom d'une classe
array[LABEL] of string: label_name; % le nom d'une étiquette
array[STUDENT] of string: student_name; % le nom des étudiants

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROPRIETES DE CLASSES : ETIQUETTAGE
array[ROOM] of set of LABEL: room_label; % les étiquettes d'une salle
array[TEACHER] of set of LABEL: teacher_label; % les étiquettes d'un enseignant
%array[GROUP] of set of LABEL: group_label; % les étiquettes d'un groupe
array[COURSE] of set of LABEL: course_label; % les étiquettes d'un cours
array[PART] of set of LABEL : part_label; % les étiquettes d'une partie
array[STUDENT] of set of LABEL: student_label; % les étiquettes des étudiants

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROPRIETE ACQUISES VIA SOLUTION : GROUPS

array[GROUP] of set of STUDENT : group_students; % les étudiants attribés à chaque groupe

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROPRIETE ACQUISES VIA SOLUTION : CLASS
array[CLASS] of set of P_TEACHER: class_teachers;
array[CLASS] of set of P_ROOM : class_rooms;
array[CLASS] of set of P_GROUP: class_groups;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PROPRIETE ACQUISES VIA SOLUTION : SESSION

array[CLASS,SESSION_RANK] of P_DAYSLOT: session_dailyslot; % Dailyslot affecter à une session 
array[CLASS,SESSION_RANK] of P_WEEKDAY: session_day; % jour hebdmodaire affecter à une session 
array[CLASS,SESSION_RANK] of P_WEEK: session_week; % semaine affecter à une session 
array[CLASS,SESSION_RANK] of set of P_ROOM: session_rooms; % ensemble de salles affecter à une session 
array[CLASS,SESSION_RANK] of set of P_TEACHER: session_teachers; % ensemble d'enseignants affecter à une session 
