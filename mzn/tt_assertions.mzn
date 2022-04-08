%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ASSERTIONS

% HORIZON DE TEMPS
constraint assert(nr_weeks > 0, "Invalid datafile: " ++  "Number of weeks should be strictly positive");
constraint assert(nr_days_per_week in 1..7, "Invalid datafile: " ++  "Number of days per week should belong to 1..7");
constraint assert(nr_slots_per_day in 1..144, "Invalid datafile: " ++  "Number of slots per days should belong to 1..24*6, ie, the minimum granularity allowed is 10 minutes each slot");


% DECOMPTES
constraint assert(nr_equipments >= 0, "Invalid datafile: " ++  "Number of equipments should be positive");
constraint assert(nr_rooms >= 0, "Invalid datafile: " ++  "Number of rooms should be positive");
constraint assert(nr_teachers >= 0, "Invalid datafile: " ++  "Number of teachers should be positive");
constraint assert(nr_groups > 0, "Invalid datafile: " ++  "Number of groups should be strictly positive");
constraint assert(nr_courses > 0, "Invalid datafile: " ++  "Number of courses should be strictly positive");
constraint assert(nr_parts >= nr_courses, "Invalid datafile: " ++  "Number of parts should be greater than or equal to the number of courses");
constraint assert(nr_classes >= nr_parts, "Invalid datafile: " ++  "Number of classes should be greater than or equal to the number of parts");
constraint assert(nr_part_equipments >= 0, "Invalid datafile: " ++  "Number of part equipments should be positive");
constraint assert(nr_part_rooms >= 0, "Invalid datafile: " ++  "Number of part rooms should be positive");
constraint assert(nr_part_teachers >= 0, "Invalid datafile: " ++  "Number of part teachers should be positive");
constraint assert(nr_scopes >= nr_constraints, "Invalid datafile: " ++  "Number of scopes should be greater than or equal to the number of constraints");
constraint assert(nr_filters >= 0, "Invalid datafile: " ++  "Number of filters should be positive");
constraint assert(nr_parameters >= 0, "Invalid datafile: " ++  "Number of parameters should be positive");

constraint assert(max_session_rank = max(c in 1..nr_courses)(max(p in course_parts[c])(part_nr_sessions[p])), "Invalid datafile: " ++  "max_session_rank inconsistent");
constraint assert(max_equipment_count = max(e in 1..nr_equipments)(equipment_count[e]), "Invalid datafile: " ++  "max_equipment_count inconsistent");
constraint assert(max_room_capacity = max(r in 1..nr_rooms)(room_capacity[r]), "Invalid datafile: " ++  "max_room_capacity inconsistent");
constraint assert(max_teacher_capacity= max(p in 1..nr_parts)(part_teacher_capacity[p]), "Invalid datafile: " ++  "max_teacher_capacity inconsistent");
constraint assert(max_group_size = max(g in 1..nr_groups)(group_size[g]), "Invalid datafile: " ++  "max_group_size inconsistent");
constraint assert(max_part_equipment_count = max(i in 1..nr_part_equipments)(part_equipment_count[i]), "Invalid datafile: " ++  "max_part_equipment_count inconsistent");
constraint assert(max_part_room_class_bound = max(i in 1..nr_part_rooms)(part_room_class_bound[i,max_resource_bound]), "Invalid datafile: " ++  "max_part_room_class_bound inconsistent");
constraint assert(max_part_teacher_class_bound = max(i in 1..nr_part_teachers)(part_teacher_class_bound[i,max_resource_bound]), "Invalid datafile: " ++  "max_part_teacher_class_bound inconsistent");

% TYPAGE DES TABLEAUX : CONFORMITE DU DOMAINE DES FONCTIONS ET MULTIFONCTIONS
constraint assert(index_set(course_parts)==1..nr_courses, "Invalid datafile: " ++  "The domain of course_parts does not comply with the expected function signature");
constraint assert(index_set(part_classes)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_classes does not comply with the expected function signature");
constraint assert(index_set(part_equipments)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_equipments does not comply with the expected function signature");
constraint assert(index_set(part_rooms)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_rooms does not comply with the expected function signature");
constraint assert(index_set(part_teachers)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_teachers does not comply with the expected function signature");
constraint assert(index_set(class_groups)==1..nr_classes, "Invalid datafile: " ++  "The domain of class_groups does not comply with the expected function signature");
constraint assert(index_set(constraint_scopes)==1..nr_constraints, "Invalid datafile: " ++  "The domain of constraint_scopes does not comply with the expected function signature");
constraint assert(index_set(scope_filters)==1..nr_scopes, "Invalid datafile: " ++  "The domain of scope_filters does not comply with the expected function signature");
constraint assert(index_set(constraint_function)==1..nr_constraints, "Invalid datafile: " ++  "The domain of constraint_function does not comply with the expected function signature");
constraint assert(index_set(function_parameters)==1..nr_constraints, "Invalid datafile: " ++  "The domain of function_parameters does not comply with the expected function signature");
constraint assert(index_set(equipment_name)==1..nr_equipments, "Invalid datafile: " ++  "The domain of equipment_name does not comply with the expected function signature");
constraint assert(index_set(equipment_count)==1..nr_equipments, "Invalid datafile: " ++  "The domain of equipment_count does not comply with the expected function signature");
constraint assert(index_set(room_name)==1..nr_rooms, "Invalid datafile: " ++  "The domain of room_name does not comply with the expected function signature");
constraint assert(index_set(room_capacity)==1..nr_rooms, "Invalid datafile: " ++  "The domain of room_capacity does not comply with the expected function signature");
constraint assert(index_set(teacher_name)==1..nr_teachers, "Invalid datafile: " ++  "The domain of teacher_name does not comply with the expected function signature");
constraint assert(index_set(group_name)==1..nr_teachers, "Invalid datafile: " ++  "The domain of group_name does not comply with the expected function signature");
constraint assert(index_set(group_size)==1..nr_groups, "Invalid datafile: " ++  "The domain of group_size does not comply with the expected function signature");
constraint assert(index_set(course_name)==1..nr_courses, "Invalid datafile: " ++  "The domain of course_name does not comply with the expected function signature");
constraint assert(index_set(part_name)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_name does not comply with the expected function signature");
constraint assert(index_set(part_nr_sessions)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_nr_sessions does not comply with the expected function signature");
constraint assert(index_set(part_length)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_length does not comply with the expected function signature");
constraint assert(index_set(part_equipment_count)==index_set(setsToArray(part_equipments)), "Invalid datafile: " ++  "The domain of part_equipment_count does not comply with the expected function signature");
constraint assert(index_set(part_room_use)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_room_use does not comply with the expected function signature");
constraint assert(index_set_1of2(part_room_class_bound)==index_set(setsToArray(part_rooms)), "Invalid datafile: " ++  "The first component of the cross-product domain of part_room_class does not comply with the expected function signature");
constraint assert(index_set_2of2(part_room_class_bound)==UTT_RESOURCE_BOUND, "Invalid datafile: " ++  "The second component of the cross-product domain of part_room_class does not comply with the expected function signature");
constraint assert(index_set(part_teacher_use)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_teacher_use does not comply with the expected function signature");
constraint assert(index_set(part_teacher_capacity)==1..nr_parts, "Invalid datafile: " ++  "The domain of part_teacher_capacity does not comply with the expected function signature");
constraint assert(index_set_1of2(part_teacher_class_bound)==index_set(setsToArray(part_teachers)), "Invalid datafile: " ++  "The first component of the cross-product domain of part_teacher_class_bound does not comply with the expected function signature");
constraint assert(index_set_2of2(part_teacher_class_bound)==UTT_RESOURCE_BOUND, "Invalid datafile: " ++  "The second component of the cross-product domain of part_teacher_class_bound does not comply with the expected function signature");
constraint assert(index_set(scope_clustering)==1..nr_scopes, "Invalid datafile: " ++  "The domain of scope_clustering does not comply with the expected function signature");
constraint assert(index_set_1of2(scope_mask)==1..nr_scopes, "Invalid datafile: " ++  "The first component of the cross-product domain of scope_mask does not comply with the expected function signature");
constraint assert(index_set_2of2(scope_mask)==PART_SESSION, "Invalid datafile: " ++  "The second component of the cross-product domain of scope_mask does not comply with the expected function signature");
constraint assert(index_set(filter_type)==1..nr_filters, "Invalid datafile: " ++  "The domain of filter_type does not comply with the expected function signature");
constraint assert(index_set(filter_elements)==1..nr_filters, "Invalid datafile: " ++  "The domain of filter_elements does not comply with the expected function signature");
constraint assert(index_set(function_type)==1..nr_constraints, "Invalid datafile: " ++  "The domain of function_type does not comply with the expected function signature");
constraint assert(index_set(parameter_value)==1..nr_parameters, "Invalid datafile: " ++  "The domain of parameter_value does not comply with the expected function signature");


% TYPAGE DES TABLEAUX : CONFORMITE DU CO-DOMAINE DES FONCTIONS ET MULTIFONCTIONS
constraint assert(forall(i in index_set(course_parts)) (course_parts[i] subset 1..nr_parts), "Invalid datafile: " ++  "The codomain of course_parts does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_classes)) (part_classes[i] subset 1..nr_classes), "Invalid datafile: " ++  "The codomain of part_classes does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_equipments)) (part_equipments[i] subset 1..nr_equipments), "Invalid datafile: " ++  "The codomain of part_equipments does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_rooms)) (part_rooms[i] subset 1..nr_rooms), "Invalid datafile: " ++  "The codomain of part_rooms does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_teachers)) (part_teachers[i] subset 1..nr_teachers), "Invalid datafile: " ++  "The codomain of part_teachers does not comply with the expected function signature");
constraint assert(forall(i in index_set(class_groups)) (class_groups[i] subset 1..nr_groups), "Invalid datafile: " ++  "The codomain of class_groups does not comply with the expected function signature");
constraint assert(forall(i in index_set(constraint_scopes)) (constraint_scopes[i] subset 1..nr_scopes), "Invalid datafile: " ++  "The codomain of constraint_scopes does not comply with the expected function signature");
constraint assert(forall(i in index_set(scope_filters)) (scope_filters[i] subset 1..nr_filters), "Invalid datafile: " ++  "The codomain of scope_filters does not comply with the expected function signature");
constraint assert(forall(i in index_set(constraint_function)) (constraint_function[i] in UTT_FUNCTION), "Invalid datafile: " ++  "The codomain of constraint_function does not comply with the expected function signature");
constraint assert(forall(i in index_set(function_parameters)) (function_parameters[i] subset 1..nr_parameters), "Invalid datafile: " ++  "The codomain of function_parameters does not comply with the expected function signature");
%constraint assert(forall(i in index_set(equipment_name)) (equipment_name[i] isstring), "Invalid datafile: " ++  "The codomain of equipment_name does not comply with the expected function signature");
constraint assert(forall(i in index_set(equipment_count)) (equipment_count[i] >= cst_null_equipment_capacity), "Invalid datafile: " ++  "The codomain of equipment_count does not comply with the expected function signature");
%constraint assert(forall(i in index_set(room_name)) (room_name[i] isstring), "Invalid datafile: " ++  "The codomain of room_name does not comply with the expected function signature");
constraint assert(forall(i in index_set(room_capacity)) (room_capacity[i] >= 0), "Invalid datafile: " ++  "The codomain of room_capacity does not comply with the expected function signature");
%constraint assert(forall(i in index_set(teacher_name)) (teacher_name[i] isstring), "Invalid datafile: " ++  "The codomain of teacher_name does not comply with the expected function signature");
%constraint assert(forall(i in index_set(group_name)) (group_name[i] isstring), "Invalid datafile: " ++  "The codomain of group_name does not comply with the expected function signature");
constraint assert(forall(i in index_set(group_size)) (group_size[i] >= 1), "Invalid datafile: " ++  "The codomain of group_size does not comply with the expected function signature");
%constraint assert(forall(i in index_set(course_name)) (course_name[i] isstring), "Invalid datafile: " ++  "The codomain of course_name does not comply with the expected function signature");
%constraint assert(forall(i in index_set(part_name)) (part_name[i] isstring), "Invalid datafile: " ++  "The codomain of part_name does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_nr_sessions)) (part_nr_sessions[i] >= 1), "Invalid datafile: " ++  "The codomain of part_nr_sessions does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_length)) (part_length[i] >= 1), "Invalid datafile: " ++  "The codomain of part_length does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_equipment_count)) (part_equipment_count[i] >= 0), "Invalid datafile: " ++  "The codomain of part_equipment_count does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_room_use)) (part_room_use[i] in UTT_RESSOURCE_USE), "Invalid datafile: " ++  "The codomain of part_room_use does not comply with the expected function signature");
constraint assert(forall(i in index_set_1of2(part_room_class_bound), j in UTT_RESOURCE_BOUND) (part_room_class_bound[i,j] >= 0), "Invalid datafile: " ++  "The codomain of part_room_class does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_teacher_use)) (part_teacher_use[i] in UTT_RESSOURCE_USE), "Invalid datafile: " ++  "The codomain of part_teacher_use does not comply with the expected function signature");
constraint assert(forall(i in index_set(part_teacher_capacity)) (part_teacher_capacity[i] >= 1), "Invalid datafile: " ++  "The codomain of part_teacher_capacity does not comply with the expected function signature");
constraint assert(forall(i in index_set_1of2(part_teacher_class_bound), j in UTT_RESOURCE_BOUND) (part_teacher_class_bound[i,j] >= 0), "Invalid datafile: " ++  "The codomain of part_teacher_class_bound does not comply with the expected function signature");
constraint assert(forall(i in index_set(scope_clustering)) (scope_clustering[i] in UTT_TYPE), "Invalid datafile: " ++  "The codomain of scope_clustering does not comply with the expected function signature");
constraint assert(forall(i in index_set_1of2(scope_mask), j in PART_SESSION) (scope_mask[i,j] in PART_SESSION_V), "Invalid datafile: " ++  "The codomain of scope_mask does not comply with the expected function signature");
constraint assert(forall(i in index_set(filter_type)) (filter_type[i] in UTT_TYPE), "Invalid datafile: " ++  "The codomain of filter_type does not comply with the expected function signature");
constraint assert(forall(i in index_set(filter_elements)) (filter_elements[i] subset UTT_ELEMENT), "Invalid datafile: " ++  "The codomain of filter_elements does not comply with the expected function signature");
constraint assert(forall(i in index_set(function_type)) (function_type[i] in UTT_HARDNESS), "Invalid datafile: " ++  "The codomain of function_type does not comply with the expected function signature");
constraint assert(forall(i in index_set(parameter_value)) (parameter_value[i] in UTT_PARAMETER), "Invalid datafile: " ++  "The codomain of parameter_value does not comply with the expected function signature");


% TYPAGE DES TABLEAUX : CONFORMITE DE L'IMAGE DES MULTIFONCTIONS - EXCLUSION DE L'ENSEMBLE VIDE
constraint assert(forall(i in index_set(course_parts)) (course_parts[i] != {}), "Invalid datafile: " ++  "The empty set cannot be in the image of course_parts");
constraint assert(forall(i in index_set(part_classes)) (part_classes[i]!={}), "Invalid datafile: " ++  "The empty set cannot be in the image of part_classes");
constraint assert(forall(i in index_set(class_groups)) (class_groups[i]!={}), "Invalid datafile: " ++  "The empty set cannot be in the image of class_groups");
constraint assert(forall(i in index_set(constraint_scopes)) (constraint_scopes[i]!={}), "Invalid datafile: " ++  "The empty set cannot be in the image of constraint_scopes");


% CONTRAINTES SUR TABLEAUX : CONFORMITE DE L'IMAGE DES MULTIFONCTIONS - PARTITIONNEMENT EN INTERVALLES ET ETIQUETTAGE CONFORME AU PARCOURS DE L'ARBRE XML INDUIT PAR L'ORDRE DE DECLARATION DES ELEMENTS  
constraint assert(partition_set(course_parts,PART), "Invalid datafile: " ++  "course_parts is a partition of the set of parts");
constraint assert(forall(i in index_set(COURSE) where i<max(COURSE)) (max(course_parts[i])+1==min(course_parts[i+1])), "Invalid datafile: " ++  "course_parts images are intervals ordered consistently with course labellings");
constraint assert(partition_set(part_classes,CLASS), "Invalid datafile: " ++  "part_classes is a partition of the set of classes");
constraint assert(forall(i in index_set(PART) where i<max(PART)) (max(part_classes[i])+1==min(part_classes[i+1])), "Invalid datafile: " ++  "part_classes images are intervals ordered consistently with part labellings");
constraint assert(partition_set(constraint_scopes,SCOPE), "Invalid datafile: " ++  "constraint_scopes is a partition of the set of scopes");
constraint assert(forall(i in index_set(CONSTRAINT) where i<max(CONSTRAINT)) (max(constraint_scopes[i])+1==min(constraint_scopes[i+1])), "Invalid datafile: " ++  "constraint_scopes images are intervals ordered consistently with constraint labellings");
constraint assert(partition_set(scope_filters,FILTER), "Invalid datafile: " ++  "scope_filters is a partition of the set of filters");
constraint assert(forall(i in index_set(SCOPE) where i<max(SCOPE)) (max(scope_filters[i])+1==min(scope_filters[i+1])), "Invalid datafile: " ++  "scope_filters images are intervals ordered consistently with scope labellings");
constraint assert(partition_set(function_parameters,PARAMETER), "Invalid datafile: " ++  "function_parameters is a partition of the set of parameters");
constraint assert(forall(i in index_set(CONSTRAINT) where i<max(CONSTRAINT)) (max(function_parameters[i])+1==min(function_parameters[i+1])), "Invalid datafile: " ++  "function_parameters images are intervals ordered consistently with constraint labellings");


% CONTRAINTES ENTRE TABLEAUX : LIENS ENTRE FONCTIONS/MULTIFONCTIONS
constraint assert(forall(i in index_set(part_classes)) (all_disjoint([class_groups[j] | j in part_classes[i]])), "Invalid datafile: " ++  "The set of groups of the classes of a part are pairwise disjoint");
constraint assert(forall(i in index_set(course_parts)) (all_equal([array_union([class_groups[k] | k in part_classes[j]]) | j in course_parts[i]])), "Invalid datafile: " ++  "The set of groups of the parts of a course all all equal");
% !! une contrainte équivalente devrait/pourrait (?) être imposée pour tous les cours d'une même filière ce qui supposerait de réifier la notion de filière dans le schéma UTT
constraint assert(min(room_capacity) >= min(group_size), "Invalid datafile: " ++  "The minimum room capacity should be greater than or equal to the minimum group size");
constraint assert(max(part_length) <= nr_slots, "Invalid datafile: " ++  "The duration of part sessions cannot exceed the span of the time horizon");
% !! only for "known" sequential classes constraint assert(max(i in PART)(part_nr_sessions[i]*part_length[i]) <= nr_slots, "Invalid datafile: " ++  "The total duration of a part cannot exceed the span of the time horizon");
constraint assert(forall(i in index_set(part_equipment_count)) (equipment_count[setsToArray(part_equipments)[i]]!=cst_null_equipment_capacity -> part_equipment_count[i]<=equipment_count[setsToArray(part_equipments)[i]]), "Invalid datafile: " ++  "A  required part equipment count cannot exceed this equipment count");
constraint assert(forall(i in index_set_1of2(part_room_class_bound)) (0 <= part_room_class_bound[i,min_resource_bound] /\ part_room_class_bound[i,min_resource_bound]<=part_room_class_bound[i,max_resource_bound]), "Invalid datafile: " ++  "Part room class bounds are consistent");
% TODO FINISH FROM HERE  constraint assert(forall(i in index_set_1of2(part_room_class_bound)) (part_room_class_bound[i,max_resource_bound]<=card(part_classes[setsToArray(part_rooms)[i]]), "Invalid datafile: " ++  "Part room class bounds are consistent");
% constraint assert(forall(i in index_set(part_teacher_use)) (part_teacher_use[i] in UTT_RESSOURCE_USE), "Invalid datafile: " ++  "The codomain of part_teacher_use does not comply with the expected function signature");
% constraint assert(forall(i in index_set(part_teacher_capacity)) (part_teacher_capacity[i] >= 1), "Invalid datafile: " ++  "The codomain of part_teacher_capacity does not comply with the expected function signature");
% constraint assert(forall(i in index_set_1of2(part_teacher_class_bound), j in UTT_RESOURCE_BOUND) (part_teacher_class_bound[i,j] >= 0), "Invalid datafile: " ++  "The codomain of part_teacher_class_bound does not comply with the expected function signature");

% constraint assert(forall(i in index_set(constraint_scopes)) (constraint_scopes[i] subset 1..nr_scopes), "Invalid datafile: " ++  "The codomain of constraint_scopes does not comply with the expected function signature");
% constraint assert(forall(i in index_set(scope_filters)) (scope_filters[i] subset 1..nr_filters), "Invalid datafile: " ++  "The codomain of scope_filters does not comply with the expected function signature");
% constraint assert(forall(i in index_set(constraint_function)) (constraint_function[i] in UTT_FUNCTION), "Invalid datafile: " ++  "The codomain of constraint_function does not comply with the expected function signature");
% constraint assert(forall(i in index_set(function_parameters)) (function_parameters[i] subset 1..nr_parameters), "Invalid datafile: " ++  "The codomain of function_parameters does not comply with the expected function signature");
% constraint assert(forall(i in index_set(scope_clustering)) (scope_clustering[i] in UTT_TYPE), "Invalid datafile: " ++  "The codomain of scope_clustering does not comply with the expected function signature");
% constraint assert(forall(i in index_set_1of2(scope_mask), j in PART_SESSION) (scope_mask[i,j] in PART_SESSION_V), "Invalid datafile: " ++  "The codomain of scope_mask does not comply with the expected function signature");
% constraint assert(forall(i in index_set(filter_type)) (filter_type[i] in UTT_TYPE), "Invalid datafile: " ++  "The codomain of filter_type does not comply with the expected function signature");
% constraint assert(forall(i in index_set(filter_elements)) (filter_elements[i] subset UTT_ELEMENT), "Invalid datafile: " ++  "The codomain of filter_elements does not comply with the expected function signature");
% constraint assert(forall(i in index_set(function_type)) (function_type[i] in UTT_HARDNESS), "Invalid datafile: " ++  "The codomain of function_type does not comply with the expected function signature");
% constraint assert(forall(i in index_set(parameter_value)) (parameter_value[i] in UTT_PARAMETER), "Invalid datafile: " ++  "The codomain of parameter_value does not comply with the expected function signature");

