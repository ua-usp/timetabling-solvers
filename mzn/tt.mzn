%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORE MODEL

% GENERIC UTILITIES
include "output.mzn";
include "log.mzn";
include "utils.mzn";

% MODEL: DATA
include "tt_bounds.mzn";
include "tt_ranges.mzn";
include "tt_arrays.mzn";
include "tt_functions.mzn";
%include "tt_assertions.mzn";

% MODEL: RULES
include "./rules/rules_solver_log.mzn";
include "./rules/rules_utils.mzn";
include "./rules/rules_solver_log.mzn";
include "./rules/rules_bounds.mzn";
include "./rules/rules_ranges.mzn";
include "tt_log.mzn";
include "tt_rules_bounds.mzn";
include "tt_rules_ranges.mzn";
include "./rules/rules_arrays.mzn";
include "tt_model_output.mzn";


% MODEL
include "tt_variables.mzn";
include "tt_predicates.mzn";
include "tt_rules_predicates.mzn";
include "tt_solution_output.mzn";
