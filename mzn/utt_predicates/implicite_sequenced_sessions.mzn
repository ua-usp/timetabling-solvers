%SESSIONS

%Verification implicite d'ordonnancement des séances
predicate implicite_sequenced_sessions()= forall(c in  CLASS)(forall(s1,s2 in class_sessions(c) where s1 <s2)(x_slot[s1]+session_length(s1)<x_slot[s2]));
