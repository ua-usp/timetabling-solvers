%Contrainte de journée. En effet une seance ne se déroule que sur  une journée.
predicate session_duration_a_day()= forall(s in SESSION)(
  let {
    var int : x_deb = x_slot[s];
    var int : x_term = x_deb+ session_length(s);
  }
  in 
  (x_deb - 1) div nr_slots_per_day == (x_term - 1) div nr_slots_per_day
);
