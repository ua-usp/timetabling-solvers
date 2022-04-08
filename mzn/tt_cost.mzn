%%%%%%%%%%%%%%%
%% COUT
% (c-cout) [dure]
constraint
  x_cost ==
        weight[k_time] * sum(c in CLASSES)(x_p_time[c]) 
    + weight[k_room] * sum(c in CLASSES)(x_p_room[c])
    + weight[k_student] * sum(s in STUDENTS)(x_p_student[s])
    + weight[k_distribution] * sum(m in DISTRIBUTIONS)(x_p_distribution[m]);