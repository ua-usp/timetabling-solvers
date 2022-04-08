
%% ALLOCATION DES GROUPES (NOMBRE DE GROUPE DANS CHAQUE CLASS)

predicate allocation_group_flex()=
forall(i_p in index_set(part_classes))(card(part_classes[i_p]) == sum(i_c in part_classes[i_p])(card(x_groups[i_c])))
;
%
