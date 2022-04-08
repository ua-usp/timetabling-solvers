%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

include "tt_predicates.mzn";
include "tt_variables.mzn";

%include "at_most.mzn";
include "cumulative.mzn";
include "disjunctive.mzn";
%include "increasing.mzn";
%include "partition_set.mzn";
include "utt_predicates/domain_class_room.mzn";
include "utt_predicates/disjunctive_group.mzn";
include "utt_predicates/allocation_room_size.mzn";
include "utt_predicates/disjunctive_room.mzn";
include "utt_predicates/domain_session_teacher.mzn";
include "utt_predicates/disjunctive_teacher.mzn";
include "utt_predicates/implicite_sequenced_sessions.mzn";
include "utt_predicates/course_no_overlap_two_day.mzn";
include "utt_predicates/allocation_teacher_option.mzn";
include "utt_predicates/part_schedule.mzn";
include "utt_predicates/teacher_hours.mzn";
include "utt_predicates/room_size_valide.mzn";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%constraint class_room_autorized();
%constraint group_disjonctive();
constraint allocation_room_size();
%constraint room_disjonctive();
/*constraint teacher_consomation();
constraint teacher_disjonctive();
constraint implicite_sequenced_sessions();
constraint session_duration_a_day();
constraint allocation_teacher_option();
constraint part_time_domain();
constraint teacher_sessions_count();*/
%constraint room_capacity_validity();


%constraint x_rooms[2] == {5}; 
%constraint x_rooms[9] == {4}; 
%constraint x_rooms[10] == {5}; 

%constraint x_teachers[58] == {2}; 
%constraint x_teachers[59] == {3}; 

%constraint x_slot[58] == 1681;
%constraint x_slot[59] == 1681;
%constraint x_slot[58] == x_slot[59]; 
%constraint allocation_teacher_option();
%constraint reparition_teacher();
%constraint equipment_assignement();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTRAINTES
/*
%% PROGRAMMATION DE SESSIONS (FSR)
% (c-s-1) [dure] Une session ne doit pas être programmée sur un créneau qui lui est interdit.
constraint
forall(s in SESSION, f in session_fsr[s])(
  not(x_slot[s] in f));

%% PLACEMENT DE CLASSES (AUTORISATIONS)
% (c-r-1) [dure] Une classe doit être placée dans une (des) salle(s) qui lui est (sont) autorisée(s).
constraint
forall(c in CLASS)(
    x_rooms[c] subset class_rooms[c]);

%% COUPLAGE SALLE POUR GROUPE ET SALLE POUR CLASSE
% (c-*-1) [dure] %TODO
constraint
forall(c in CLASS, g in class_groups(c))(
      (class_multiroom[c]==no_room -> x_room[g]==cst_null_room)
  /\ (class_multiroom[c]!=no_room -> x_room[g] in x_rooms[c]));

%% ALLOCATION DE SALLES (CLASSES SANS SALLES, MONO-SALLE, OU MULTI-SALLES)
% (c-r-1) [dure] Une classe doit être placée dans un nombre de salles conforme à son type.
constraint
forall(c in CLASS)(
      (class_multiroom[c]==no_room <-> x_room[c]=={})
  /\ (class_multiroom[c]==single_room -> card(x_room[c])==1)
  /\ (class_multiroom[c]==multiple_rooms -> card(x_room[c])>0));

%% CONSOMMATION D'EQUIPEMENTS
% (c-e-1) [dure] Un équipement doit avoir la capacité suffisante pour satisfaire aux demandes cumulées des sessions des parties les exigeant.
constraint
forall(e in EQUIPMENT)(
let {
  set of int: EFSR = index_set(equipment_fsrs[e]);%TODO check case index_set({})
  array[EFSR] of SLOT: equipment_fs_starts = [min(equipment_fsrs[e,i]) | i in EFSR];
  array[EFSR] of DURATION: equipment_fs_durations = [duration(equipment_fsrs[e,i]) | i in EFSR];
  array[EFSR] of SssssssNS_SSCAPACITY: equipment_fs_demands = [equipment_capacity[e] | i in EFSR];
} in
  cumulative(
    [x_slot[s]                         | s in equipment_sessions(e)] ++ equipment_fs_starts,
    [cst_dayslot_duration      | s in equipment_sessions(e)] ++ equipment_fs_durations,
    [equipment_demand
    
    
    (s,e) | s in equipment_sessions(e)] ++ equipment_fs_demands,
    equipment_capacity[e])); % capacité

%% UTILISATION DE SALLES
% (c-r-2) [dure] Les sessions des classes placées dans une salle non-partageable doivent être séquencées en dehors de ses plages interdites.
constraint
forall(r in ROOM where room_sharability[r]==unsharable)(
let {
  set of int: RFSR = index_set(room_fsrs[r]);%TODO check case index_set({})
  array[RFSR] of SLOT : room_fs_starts = [min(room_fsrs[r,i]) | i in RFSR];
  array[RFSR] of DURATION : room_fs_durations = [duration(room_fsrs[r,i]) | i in RFSR];
} in
  disjunctive(
    [x_slot[s]                                                                                  | s in room_sessions(r)] ++ room_fs_starts,
    [cst_dayslot_duration*bool2int(r in x_rooms[session_class(s)]) | s in room_sessions(r)] ++ room_fs_durations));
    
% (c-r-3) [dure] Une salle partageable doit avoir la capacité suffisante en dehors de ses plages interdites pour héberger les sessions des classes auxquelles elle est allouée.
constraint
forall(r in ROOM where room_sharability[r]==sharable)(
let {
  set of int: RFSR = index_set(room_fsrs[r]);%TODO check case index_set({})
  array[RFSR] of SLOT: room_fs_starts = [min(room_fsrs[r,i]) | i in RFSR];
  array[RFSR] of DURATION: room_fs_durations = [duration(room_fsrs[r,i]) | i in RFSR];
  array[RFSR] of R_CAPACITY: room_fs_demands = [room_capacity[r] | i in RFSR];
} in
  cumulative(
    [x_slot[s]                                                     | s in room_sessions(r)] ++ room_fs_starts[r],
    [cst_dayslot_duration                                  | s in room_sessions(r)] ++ room_fs_durations,
    [sum(g in class_groups(session_class(s)))
        (group_size[g]*bool2int(r==x_room[g])) | s in room_sessions(r)] ++ room_fs_demands,
    room_capacity[r])); % capacité
    

%% AFFECTATION D'ENSEIGNANTS
% (c-t-1) [dure] Les sessions des classes placées affectée à un enseignant non-ubiquitaire doivent être séquencées en dehors de ses plages interdites.
constraint
forall(t in TEACHER where teacher_ubiquity[t]==unubiquitous)(
let {
  set of int: TFSR = index_set(teacher_fsrs[r]);%TODO check case index_set({})
  array[TFSR] of SLOT : teacher_fs_starts = [min(teacher_fsrs[r,i]) | i in TFSR];
  array[TFSR] of DURATION : teacher_fs_durations = [duration(teacher_fsrs[r,i]) | i in TFSR];
} in
  disjunctive(
    [x_slot[s]                                                                                     | s in teacher_sessions(t)] ++ teacher_fs_starts,
    [cst_dayslot_duration*bool2int(t in x_teachers[session_class(s)]) | s in teacher_sessions(r)] ++ teacher_fs_durations));

% DISJONCTION GROUPS
constraint
  forall(g in GROUPS)(
      disjunctive(
        [x_slot[i] | c in group_classes[t], i in class_sessions[c]],
        [1           | c in group_classes[t], i in class_sessions[c]]
      )
;


*/
%%%%%%%%%%%%


%TODO penalty
% % (c-r-2) [souple] La programmation d'une classe sur une séance induit une pénalité.
% constraint
%   forall(c in CLASSES)(
%       x_p_time[c] == time_penalty[x_time[c]]
%     )
% ;

%TODO
% % (c-a-2) [souple] Le positionnement d'une classe dans une salle induit une pénalité.
% constraint
%   forall(c in CLASSES)(
%       x_p_room[c] == room_penalty[c,x_room[c]] % ! 0 par sémantique relationnelle de mzn si salle nulle
%     )
% ;

% %% DIMENSIONNEMENT/ENROLEMENT (EFFECTIFS)
% % (c-d-1) [dure] L'effectif d'une classe est le nombre d'étudiants enrôlés dans la classe.
% constraint
%   forall(c in CLASSES)(
%       x_headcount[c] == sum(s in STUDENTS)(bool2int(enrolled(s,c)))
%     )
% ;

% %% DIMENSIONNEMENT (LIMITES)
% % (c-d-2) [dure] L'effectif d'une classe ne peut dépasser son seuil autorisé.
% constraint
%   forall(c in CLASSES)(
%       x_headcount[c] <= limit[c]
%     )
% ;

% %% ENROLEMENT (INSCRIPTIONS)
% % (c-e-1) [dure] Un étudiant ne peut être enrôlé que dans des classes de cours auxquels il est inscrit.
% constraint
%   forall(s in STUDENTS, c in CLASSES)(
%       enrolled(s,c) -> registered(s,c)
%     )
% ;

% %% ENROLEMENT (CONFIGURATION)
% % (c-e-2) [dure] Un étudiant ne peut être enrôlé que dans les classes associées à chaque classe-type.
% constraint
%   forall(e in STUDENTS, s in SUBPARTS)(
%       x_class[e,s] in classes[s] union {cst_null_class}
%     )
% ;

% %% ENROLEMENT (SECTIONNEMENT) 
% % (c-e-4) [dure] Pour chaque cours auquel il est inscrit, un étudiant est enrôlé dans une classe par classe-type d'une des configurations du cours.
% constraint
%   forall(e in STUDENTS, u in COURSES where u in registrations[e])(
%     sum(p in configs[u])(product(s in subparts[p])(sum(c in classes[s])(bool2int(x_class[e,s]==c)))) == 1
%     )
% ;

% % (c-e-5) [dure] Un étudiant n'est enrôlé dans aucune des classes des des cours auxquels il n'est pas inscrit.
% % Force l'affectation de la classe nulle.
% constraint
%   forall(e in STUDENTS, u in COURSES where not (u in registrations[e]))(
%     sum(p in configs[u])(sum(s in subparts[p])(sum(c in classes[s])(bool2int(x_class[e,s]==c)))) == 0
%     )
% ;

% % (c-e-7) [dure] Un étudiant enrôlé dans une classe enfant doit l'être dans la classe parente.
% constraint
%   forall(s in STUDENTS, c in CLASSES where parent[c]!=cst_null_class)(
%      enrolled(s,c) -> enrolled(s,parent[c])
%     )
% ;

% % % PROGRAMMATION/ENROLEMENT (SEQUENCAGE PAR ETUDIANT)
% % (c-r-2) [souple] Une pénalité de 1 est encourue pour tout étudiant et toute paire de classes dans lequelles il est enrôlé si leurs séances se chevauchent ou ne garantissent pas un temps de déplacement suffisant entre leurs salles le cas échéant.
% % !! Clause restreinte aux cours auxquels l'étudiant est inscrit du fait de (c-e-1) et non explicitement conditionnée à leur ouverture du fait de (c-e-2)
% constraint
%   forall(e in STUDENTS)(
%     x_p_student[e] == 0
% %      sum(c1,c2 in CLASSES where c1<c2 /\ c1 in student_classes[e] /\ c2 in student_classes[e])(
% %        1 - bool2int(
% %          (enrolled(e,c1) /\ enrolled(e,c2))
% %          ->
% %          same_attendees({c1,c2})
% %        )
% %      )
%   )
% ;

% %% POSITIONNEMENT (CAPACITE DE SALLE REELLE)
% % (c-a-3) [dure] Une salle doit avoir une capacité d'accueil suffisante pour héberger l'effectif enrôlé dans chacune des classes qui l'occupe.
% constraint
%    forall(r in ROOMS, c in room_classes[r])(
%       (x_rc_duration[r,c]==1) -> (capacity[r]>=x_headcount[c]) 
%    )
% ;

%% POSITIONNEMENT (PRE-FERMETURES ET SEQUENCEMENT PAR SALLE RELLE)
% (c-a-4) [dure] Une salle ne peut être allouée qu'à une classe à la fois par créneau, et en dehors de ses créneaux de fermeture.
% contrainte d'ordonnancement disjonctif : puisqu'une salle ne peut être allouée qu'à une seule séance par unité de temps, on utilise la contrainte `disjunctive`(équivalente à contrainte `cumulative` avec capacité de salle fixée à 1) et on simule l'occupation des créneaux sur les périodes prédéfinies de fermeture
% !! Clause restreinte aux salles autorisées pour une classe du fait de (c-a-1)

%% Contrainte de capacité redondante
% constraint
%   forall(r in ROOMS where c1, c2 in CLASSES where c1 < c2 /\ x_room[c1] == r /\ x_room[c2] == r)(
%     not_overlap([c1,c2])
%   )
% ;

%% Contrainte de capacité redondante
% constraint
%   forall(r in ROOMS, s in SLOTS where {t | t in room_times[r] where open_slots[t,s]==1}!={})(
% %   trace("\n room : "++ show(r) ++ " - slot " ++ show(s) ++ " - room_closed_slot " ++ show(room_closed_slots[r,s]) ++  "classes " ++ show({class[t] | t in room_times[r] where open_slots[t,s]==1}) ++  "times " ++ show({t | t in room_times[r] where open_slots[t,s]==1}),true) /\
%        sum(t in room_times[r] where open_slots[t,s]==1)(bool2int(x_time[class[t]]==t)*bool2int(x_room[class[t]]==r)) <= (1 - room_closed_slots[r,s])
%   ) 
% ;

%% Contrainte de capacité redondante
% constraint
%   forall(r in ROOMS, s in SLOTS where room_closed_slots[r,s]==0 /\  {t | t in room_times[r] where open_slots[t,s]==1}!={})(
%        atmost(1,[(x_time[class[t]]==t /\ x_room[class[t]]==r) | t in room_times[r] where open_slots[t,s]==1],true)
%   ) 
% ;

%% Contrainte de capacité redondante
% constraint
%   forall(r in ROOMS, s in SLOTS where room_closed_slots[r,s]==1 /\  {t | t in room_times[r] where open_slots[t,s]==1}!={})(
%        forall(t in room_times[r] where open_slots[t,s]==1)(x_time[class[t]]!=t \/ x_room[class[t]]!=r)
%   ) 
% ;

% constraint
%   forall(r in ROOMS, w in WEEKS where room_week_classes[r,w]!={})(
%     let { array[int] of WEEKLY_SLOTS : room_closure_weekly_slots = [weeklySlot(weekday[s],dayslot[s]) | s in SLOTS where week[s]==w /\ room_closed_slots[r,s]==1];
%            array[int] of DURATION : room_closure_count = [1 | s in index_set(room_closure_weekly_slots)];
%     }
%     in
%       disjunctive(
%         [x_w_start[c] | c in room_week_classes[r,w]] ++ room_closure_weekly_slots,
%         [x_rc_duration[r,c] | c in room_week_classes[r,w]] ++ room_closure_count
%       )
%     )
% ;

%% Contrainte de capacité redondante : sur pool de salles interchangeables par semaine
% array[ROOMS,WEEKS] of set of ROOMS: room_pool = array2d(ROOMS,WEEKS,[{ rj | rj in ROOMS where room_week_classes[ri,w]==room_week_classes[rj,w] /\ room_classes[rj]==room_classes[ri]} | ri in ROOMS, w in WEEKS]);
% constraint
%   forall(r in ROOMS, w in WEEKS where card(room_pool[r,w])>1 /\ r==min(room_pool[r,w]))(
%     let { array[int] of SLOTS : room_closure_slots = [s | s in SLOTS where week[s]==w /\ exists(r in room_pool[r,w])(room_closed_slots[r,s]==1)];
%            array[int] of WEEKLY_SLOTS : room_closure_weekly_slots = [weeklySlot(weekday[s],dayslot[s]) | s in room_closure_slots];
%            array[int] of DURATION : room_closure_count = [card({rj | rj in room_pool[r,w] where room_closed_slots[r,s]==1}) | s in room_closure_slots];
%     }
%     in
%    trace("\n room : "++ show(r) ++ "room pool " ++ show(room_pool[r,w]),true) /\
%       cumulative(
%         [x_w_start[c] | c in room_week_classes[r,w]] ++ room_closure_weekly_slots, % start times
%         [1 | c in room_week_classes[r,w]] ++ room_closure_count, % durations
%         [1 | c in room_week_classes[r,w]] ++ room_closure_count, % consumption
%         card(room_pool[r,w]) % capacity
%       )
%     )
% ;

%% POSITIONNEMENT (PRE-FERMETURES ET ORDONNANCEMENT PAR SALLE RELLE)
% (c-a-5) [dure] Une salle doit avoir une capacité d'accueil suffisante pour héberger l'effectif enrôlé dans chacune des classes qui l'occupe en dehors de ses créneaux de fermeture.
% constraint
%   forall(r in ROOMS)(
%     let{
%       var set of CLASSES: cds = {c | c in CLASSES where x_room[c] == r} % cds : classes dans salle
%     } in
%       forall(cc in cds)(
%         let{
%           var set of CLASSES: meme_temp = {c | c in cds where 
%             time_weeks[x_time[c]] intersect time_weeks[x_time[cc]] != {}
%             /\
%             time_days[x_time[c]] intersect time_days[x_time[cc]] != {}
%             /\
%             (
%               (time_start[x_time[c]] + time_length[x_time[c]] > time_start[x_time[cc]] /\ time_start[x_time[c]] < time_start[x_time[cc]])
%               \/
%               (time_start[x_time[cc]] + time_length[x_time[cc]] > time_start[x_time[c]] /\ time_start[x_time[cc]] < time_start[x_time[c]])
%             )
%             }
%         } in
%         sum(cla in meme_temp)(x_headcount[cla]) <= capacity[r]
%       )
%   )
% ;
/*
% same_start
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_start)(
      same_start([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_start)(
      x_p_distribution[m] = (1 - bool2int(same_start([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;


% same_time
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_time)(
      same_time([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_time)(
      x_p_distribution[m] = (1 - bool2int(same_time([c | c in distribution_scope[m]]))) * card(distribution_scope[m])

    )
;

% different_time
constraint
  forall(m in typed_distributions[hard] where distribution[m]==different_time)(
      different_time([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==different_time)(
      x_p_distribution[m] = (1 - bool2int(different_time([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% same_days
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_days)(
      same_days([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_days)(
      x_p_distribution[m] = (1 - bool2int(same_days([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% different_days
constraint
  forall(m in typed_distributions[hard] where distribution[m]==different_days)(
      different_days([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==different_days)(
      x_p_distribution[m] = (1 - bool2int(different_days([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% same_weeks
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_weeks)(
      same_weeks([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_weeks)(
      x_p_distribution[m] = (1 - bool2int(same_weeks([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% different_weeks
constraint
  forall(m in typed_distributions[hard] where distribution[m]==different_weeks)(
      different_weeks([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==different_weeks)(
      x_p_distribution[m] = (1 - bool2int(different_weeks([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% same_room
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_room)(
      same_room([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_room)(
      x_p_distribution[m] = (1 - bool2int(same_room([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% different_room
constraint
  forall(m in typed_distributions[hard] where distribution[m]==different_room)(
      different_room([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==different_room)(
      x_p_distribution[m] = (1 - bool2int(different_room([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% overlap
constraint
  forall(m in typed_distributions[hard] where distribution[m]==overlap)(
      overlap([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==overlap)(
      x_p_distribution[m] = (1 - bool2int(overlap([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% not_overlap
constraint
  forall(m in typed_distributions[hard] where distribution[m]==not_overlap)(
      not_overlap([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==not_overlap)(
      x_p_distribution[m] = (1 - bool2int(not_overlap([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

% same_attendees
constraint
  forall(m in typed_distributions[hard] where distribution[m]==same_attendees)(
      same_attendees([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==same_attendees)(
      x_p_distribution[m] = (1 - bool2int(same_attendees([c | c in distribution_scope[m]]))) * card(distribution_scope[m])
    )
;

%precedence
constraint
  forall(m in typed_distributions[hard] where distribution[m]==precedence)(
      precedence([c | c in distribution_scope[m]])
    )
;

constraint
  forall(m in typed_distributions[soft] where distribution[m]==precedence)(
    let { array[int] of CLASSES: sc = [c | i in CLASSES, c in CLASSES where distribution_classes[m,i]!=0 /\  distribution_classes[m,i]=c]}
    in
      x_p_distribution[m] = (1 - bool2int(precedence(sc))) * length(sc)
    )
;
*/