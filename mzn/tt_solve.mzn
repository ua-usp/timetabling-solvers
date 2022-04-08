%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESOLUTION

% input_order: choose in order from the array
% first_fail: choose the variable with the smallest domain size, and
% smallest: choose the variable with the smallest value in its domain.
% dom_w_deg: choose the variable with the smallest value of domain size divided by weighted degree, which is the number of times it has been in a constraint that caused failure earlier in the search.

% indomain_min: assign the variable its smallest domain value,
% indomain_median: assign the variable its median domain value,
% indomain_random: assign the variable a random value from its domain, and
% indomain_split bisect the variables domain excluding the upper half.

solve 
 :: seq_search([
   %set_search(x_rooms, input_order, indomain_min),

    %set_search(x_rooms, input_order, indomain_min),
   % int_search(x_slot, input_order, indomain_min),
   %set_search(x_teachers, input_order, indomain_min),
%   set_search(x_teachers, first_fail, indomain_random),
    set_search(x_rooms, input_order, indomain_min),
       set_search(x_teachers, input_order, indomain_min),
   int_search(x_slot, smallest, indomain_min)
  ])
   %:: restart_linear(200)
  satisfy;
  %minimize sum(s in SESSION)(x_slot[s]);
/*
solve 
 :: seq_search([
%   int_search(x_headcount, input_order, indomain_max),
   int_search(x_class, first_fail, indomain_min),
   int_search(x_w_start, input_order, indomain_min),
   int_search(x_time, input_order, indomain_min),
   int_search(x_room, first_fail, indomain_random),
  ])
  satisfy;
% minimize x_cost;
*/
