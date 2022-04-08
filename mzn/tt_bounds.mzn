%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BORNES ET CONSTANTES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BORNES EN ENTREE
int: nr_weeks; % nombre de semaines sur l'horizon de temps
int: nr_days_per_week; % nombre de journées hebdomadaires
int: nr_slots_per_day; % nombre de créneaux quotidiens

int: nr_courses; % nombre de cours
int: nr_parts; % nombre de parties
int: nr_classes; % nombre de classes
int: nr_sessions; % nombre de séances
int: max_part_sessions; % nombre de séances maximum par partie

int: nr_equipments; % nombre d'équipements
int: nr_rooms; % nombre de salles
int: nr_teachers; % nombre d'enseignants
int: nr_groups; % nombre de groupes d'étudiants
int: nr_students; % nombre d'étudiants

int: nr_part_rooms; % cumul du nombre de salles (allouables) par partie
int: nr_part_teachers; % cumul du nombre d'enseignants (alloués) par partie

int: max_equipment_count;  % décompte maximum recensé sur les équipements
int: max_room_capacity; % capacité maximum recensée sur les salles
int: max_group_headcount; % taille d'effectif maximum recensée sur les groupes
int: max_teacher_session; % nombre maximum d'enseignant par session
int: max_teacher_sessions; % nombre maximum de sessions pour les enseignants
int: max_class_maxheadcount; % effectif maximum possible pour les classes

int: nr_part_room_mandatory;% cumul du nombre de salles requises (à allouer obligatoirement) par partie %TODO supprimer pour autre formulation?

int: nr_labels;% nombre d'étiquettes


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BORNES AUXILIAIRES
% nombre de créneaux hebdomadaires
int: nr_weekly_slots = nr_days_per_week * nr_slots_per_day;
 % nombre de créneaux sur l'horizon de temps
 int: nr_slots = nr_weeks * nr_weekly_slots;
% nombre total de séances
%int: nr_sessions = sum(c in 1..nr_courses)(sum(p in course_parts[c])(card(part_classes[p])*part_nr_sessions[p])); %TODO as assertion
% taille des effectifs cumulés des groupes
int: total_group_headcount = sum(g in 1..nr_groups)(group_headcount[g]); %TODO should be given as input data to allow for proper inclusion order: bounds -> ranges -> arrays

% nombre maximum de salles par partie
int: max_part_rooms = max(p in PART)(card(part_rooms[p]));  % TODO: devrait prendre en compte 'single/multiple'
% nombre maximum d'enseignants par partie
int: max_part_teachers = max(p in PART)(card(part_teachers[p]));


%TODO  int: nr_criteria = 4;