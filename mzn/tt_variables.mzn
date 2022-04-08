%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VARIABLES

include "tt_arrays.mzn";


%% VARIABLES DE PROGRAMMATION DE CRENEAUX
% (x-s-1) Créneau choisi par session
array[SESSION] of var SLOT: x_slot;

%% VARIABLES D'ALLOCATION D'ENSEMBLE DE SALLES AUX CLASSES
% (x-r-1) Salles choisies par classe : 1 seule salle pour classe mono-salle
array[CLASS] of var set of ROOM: x_rooms;

%% VARIABLES D'ALLOCATION DE SALLE PAR GROUPE
% (x-g-1) Salle choisie par groupe
%array[GROUP] of var ROOM_P: x_room;
%array[CLASS] of var set of TEACHER: x_teachers;
array[SESSION] of var set of TEACHER: x_teachers;

%TODO cost
% %% VARIABLES DE COUT
% % TODO le domaine de chaque variable serait à borner par contraintes ou plage pré-calculée
% % (x-p-1) pénalités encourues pour réservation de programme par classe
% array[CLASS] of var COST_RANGE[k_time]: x_p_time; % 
% % (x-p-2) pénalités encourues pour allocation de salle par classe
% array[CLASS] of var COST_RANGE[k_room]: x_p_room; % 
% % (x-p-3) pénalités encourues pour préférence de séquençage par étudiant
% array[GROUP] of var COST_RANGE[k_student]: x_p_student; % 
% % (x-p-4) pénalités encourues pour préférence de distribution
% array[UTT_CONSTRAINT] of var COST_RANGE[k_distribution] : x_p_distribution; % COST_RANGE[k_distribution]
% % (x-p-5) coût de l'edt
% var COST: x_cost;

% TODO useful ??
% array[CLASS] of var WEEKLY_SLOT: x_w_start;
% array[GROUP,CLASS] of var DURATION: x_ec_duration;
% array[ROOM,CLASS] of var DURATION: x_rc_duration;
