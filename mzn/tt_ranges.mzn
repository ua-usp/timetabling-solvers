%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTANTES, CATEGORIES, CLASSES ET DIMENSIONS
%%
%% Une classe est un ensemble fini d'éléments identifiables.
%% Une catégorie est un ensemble fini constant (instance-indépendant) d'éléments identifiables.
%% Une dimension est un domaine de valeurs entières.
%%  
%% Toute U-classe se définit par une plage d'entiers normalisée (ie. démarrant à 1) identifiant ses éléments.
%% Toute U-catégorie se définit par une plage d'entiers normalisée identifiant ses éléments.
%% Toute U-dimension se définit par une plage d'entiers.
%%
%% Toute catégorie se définit par une énumération MZN d'entiers nommés (ie. une plage constante).
%% Toute classe se définit par un ensemble d'entiers MZN.
%% Toute dimension se définit par un ensemble d'entiers MZN.
%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LES CLASSES D'UTT-ELEMENTS
%%
%% Les éléments identifiés dans une instance UTT, appelés *UTT-éléments*, se scindent en différentes classes :
%% - les équipements (classe `utt_equipment`)
%% - les salles (classe `utt_room`)
%% - les enseignants (classe `utt_teacher`)
%% - les étudiants (class `utt_students`)
%% - les groupes d'étudiants (classe `utt_group`)
%% - le champ des formations (classe `utt_courses`)
%% - les cours des formations (classe `utt_course`)
%% - les parties de cours (classe `utt_part`)
%% - les classes de parties (classe `utt_class`)
%% - les séances de classes (classe `utt_session`}.
%%
%% Les classes sont normalisées.
%% Le champ des formations est une classe singleton.
%% L'ensemble des classes forme une catégorie notée `UTT_TYPE`.
%% L'union des classes forme une classe notée `UTT_ELEMENT`.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

include "tt_padding.mzn";
include "tt_bounds.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONSTANTES GENERIQUES

%%% ELEMENTS VIRTUELS
% On ajoute à certaines classes ou dimensions un *élément nul* modélisant une valeur fictive afin de réifier l'absence ou l'optionalité de représentation.
% La valeur adoptée peut simplifier - ou non ! - l'expression de contraintes.
int: cst_null_session = 0; % séance fictive
int: cst_null_room = 0; % salle fictive allouée à une séance n'exigeant aucune salle
int: cst_null_teacher = 0; % enseignant fictif affecté à une séance n'exigeant aucun enseignant

int: cst_null_session_rank = 0; % rang de séance fictif

int: cst_null_equipment_capacity = -1; % capacité illimitée d'équipement
int: cst_null_equipment_demand = -1; % demande fictive de partie en équipements
int: cst_null_room_capacity = -1; % capacité illimitée de salle
int: cst_null_group_headcount = -1; % taille illimitée (?) de groupe


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CATEGORIES

enum UTT_RESOURCE_USE = {none,single,multiple,all,star}; % les politiques d'allocation de ressources unitaires (salles, enseignants) %TODO any : reserved MZN keyword?
array[UTT_RESOURCE_USE] of string: utt_resource_use_name = ["none","single","multiple","all","star"];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CLASSES

set of int: COURSE = 1..nr_courses; % les cours
set of int: PART = 1..nr_parts; % les parties
set of int: CLASS = 1..nr_classes; % les classes
set of int: SESSION = 1..nr_sessions; % les séances

set of int: EQUIPMENT = 1..nr_equipments; % les équipements-types
set of int: ROOM = 1..nr_rooms; % les salles
set of int: TEACHER = 1..nr_teachers; % les enseignants
set of int: GROUP = 1..nr_groups; % les groupes
set of int: STUDENT= 1..nr_students; % les étudiants

set of int: PART_ROOM = 1..nr_part_rooms; % les salles de parties %TODO non source actuellement mais devrait pas symmétrie avec PART_TEACHER
set of int: PART_TEACHER = 1..nr_part_teachers; % les enseignants de parties

set of int: PART_ROOM_MANDATORY=1..nr_part_room_mandatory; % TODO revoir (cf PART_ROOM)

set of int: LABEL = 1..nr_labels; % les étiquettes

%%% Classes virtualisées
set of int: SESSION_V = {cst_null_session} union SESSION; % séance
set of int: ROOM_V = {cst_null_room} union ROOM; % salle
set of int: TEACHER_V = {cst_null_teacher} union TEACHER; % enseignant


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DIMENSIONS

set of int: WEEK = 1..nr_weeks; % les semaines de l'horizon de temps
set of int: WEEKDAY = 1..nr_days_per_week;  % les journées hebdomadaires
set of int: SLOT = 1..nr_slots; % les créneaux de l'horizon
set of int: WEEKLY_SLOT = 1..nr_weekly_slots; % les créneaux hebdomadaires % TODO rename WEEKSLOT
set of int: DAYSLOT = 1..nr_slots_per_day;  % les créneaux quotidiens
set of int : DAY = 1..nr_days_per_week*nr_weeks;% les jours sur l'horizons

set of int: SESSION_RANK = 1..max_part_sessions; % les rangs de séances de parties

set of int: E_COUNT = 0..max_equipment_count; % les capacités d'équipement-types en appoint de séance mesurée, par convention, en nombre d'équipements
set of int: R_CAPACITY = 0..max_room_capacity; % les capacités de salles en hébergement de séance mesurée, par convention, en nombre d'étudiants
set of int: G_HEADCOUNT = 0..max_group_headcount; % taille de groupe
set of int: T_COUNT = 0..max_teacher_session; % nombre de teacher par cours
set of int: T_SESSIONS = 0..max_teacher_sessions; % nombre sessions pour chaque enseignant
set of int: C_MAXHEADCOUNT = 0..max_class_maxheadcount; % le nombre maximum d'étudiants par class

%PADDING DIMENSIOn

set of int: P_TEACHER = padding_set[1] union padding_set[2] union TEACHER; % les enseignants et une valeur par défaut
set of int: P_ROOM = padding_set[1] union padding_set[2] union ROOM; % les enseignants et une valeur par défaut
set of int: P_GROUP = padding_set[1] union padding_set[2] union GROUP; % les enseignants et une valeur par défaut

set of int: P_DAYSLOT = padding_set[1] union padding_set[2] union DAYSLOT;  % les créneaux quotidiens
set of int: P_WEEKDAY = padding_set[1] union padding_set[2] union WEEKDAY;  % les journées hebdomadaires
set of int: P_WEEK = padding_value_with_name("paddingUnknowValue") union padding_value_with_name("paddingImpossibleValue") union WEEK; % les semaines de l'horizon de temps

%%% Dimensions virtualisées
set of int: SESSION_RANK_V = {cst_null_session_rank} union SESSION_RANK; % rang de séance de partie

set of int: E_COUNT_V = {cst_null_equipment_capacity} union E_COUNT; % capacité d'équipement
set of int: R_CAPACITY_V = {cst_null_room_capacity} union R_CAPACITY; % capacité de salle
set of int: G_HEADCOUNT_V = {cst_null_group_headcount} union G_HEADCOUNT; % taille de groupe
set of int: C_PARENT = {padding_value[1]} union CLASS;

%set of int: WEIGHT = 0..10; %TODO à borner avec constance d'instance ou à calculer en fonction des dimensions de l'instance de sorte à pouvoir ordonner les critères lexicographiquement
set of int: HEADCOUNT = 0..total_group_headcount; % les tailles d'effectifs mesurée en nombre d'étudiants

%%% Décomptes
set of int: SLOTS = 0..max(SLOT); % décompte de créneaux (ie. durée)
set of int: SESSIONS = 0..max(SESSION); % décompte de séances
