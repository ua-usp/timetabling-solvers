%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BORNES ET CONSTANTES

include "tt_bounds.mzn";
include "./rules/rules_bounds.mzn";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CONSTANTES

% valeur fictive délimitant la fin d'un q-quark (séance fictive)
qquark_padder = 0; 

% valeur fictive délimitant la fin d'un masque
mask_padder = 0;
