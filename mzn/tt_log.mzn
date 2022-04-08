%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOGGING

include "./rules/rules_solver_log.mzn";


% Traits de logging
enum UTT_LOG = {
% TODO rename utt_log_*
u_lutils, % utilitaires
u_betatest % 
}
++ C(RS_LOG);
