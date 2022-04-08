%read data domain of part

predicate part_time_domain() = 
/*let{
int : days = card(part_days[p]);
int : dailyslots = card(part_dailyslots[p]);
int : weeks = card(part_weeks[p]);

int : semaine_size = days * dailyslots;


int : size_set_domain = card(part_days[p]) * card(part_dailyslots[p]) *card(part_weeks[p]);
array[int] of int : tab_week = set2array(part_weeks[p]) ;
array[int] of int : tab_day = set2array(part_days[p]) ;
array[int] of int : tab_dayslot = set2array(part_dailyslots[p]) ;

array[int ] of int : tab_tmp = [(((i-1)div semaine_size)*nr_weekly_slots) + (((((i-1) mod semaine_size)-1)div days)* nr_slots_per_day) + 1 | i in 1..size_set_domain]



%array[int ] of int : tab_tmp = [(tab_week[(i div card(part_weeks[p]))+1] -1) * nr_weekly_slots + (tab_day[(i mod card(part_days[p]))+1] - 1 ) * nr_slots_per_day +  tab_dayslot[(i mod card(part_dailyslots[p]))+1] | i in 1..size_set_domain];

  int: a1 =0;
set of int : slot_tmp = {(tab_week[(i mod card(part_weeks[p]))+1] - 1) * nr_weekly_slots + (tab_day[(i mod card(part_days[p]))+1] - 1 ) * nr_slots_per_day +  tab_dayslot[(i mod card(part_dailyslots[p]))+1] | i in 1..size_set_domain};
} in */
forall(p in PART)(
  forall(s in part_sessions(p))(
    (slot_week(x_slot[s]) in part_weeks[p]) /\
    (slot_weekday(x_slot[s]) in part_days[p]) /\ (slot_dayslot(x_slot[s]) in part_dailyslots[p])
  )
)
/*
if(p == 1) then  -1<my_trace(u_lupredicate,"aspect des valeurs ",tab_tmp) /\
forall(s in part_sessions(p))(x_slot[s] in slot_tmp )
else 
true endif*/

%(part_weeks[p] - 1) * nr_weekly_slots + (part_days[p] - 1 ) * nr_slots_per_day +  part_dailyslots[p]

  ;