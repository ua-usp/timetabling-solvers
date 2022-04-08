%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MODEL OUTPUT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FORMATS AND CLI PARAMETERS

% Output format types
enum U_OUTPUT_FORMAT = {
u_custom, % custom text format
u_dzn, % DZN format
u_json, % general JSON format
u_json_mzn % MZN-specific JSON format
};

% Output cut
enum U_OUTPUT_CUT = {
u_cut, % custom text format
u_no_cut
};

% Output switch (CLI parameter)
bool: u_output;

% Output format (CLI parameter)
U_OUTPUT_FORMAT: u_output_format;

% Output cut (CLI parameter)
U_OUTPUT_CUT:u_output_cut;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FORMAT-SPECIFIC EXPANSION OF SPECIAL CHARACTERS

% object property key-value separator
function string: key_value_separator() =
  if       u_output_format == u_dzn
  then "="
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then  " : " 
  else  " := " 
  endif;

% array/set elements separator
function string: elements_separator() =
  if       u_output_format == u_dzn
  then ","
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then  "," 
  else  " , " 
  endif;

% object members separator
function string: members_separator(bool: trailing_comma) =
  if       u_output_format == u_dzn
  then ";"
  elseif (u_output_format == u_json \/ u_output_format == u_json_mzn) /\ trailing_comma==true
  then  "," 
  elseif (u_output_format == u_json \/ u_output_format == u_json_mzn) /\ trailing_comma==false
  then  "" 
  else  " , " 
  endif;

% newline with indentation
function string: newline_indent(int: tab) =
  "\n"
  ++ join(" ",[" " | i in 1..tab])
  ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FORMAT-SPECIFIC EXPANSION OF VALUES

%
function string: json_quote_bool(bool: value) =
  if value
  then "\"true\""
  else "\"false\""
  endif;

%
function string: dzn_quote_set(set of int: value) =
  let {
  array[int] of int: t = set2array(value);
  } in
  "{" ++ join(elements_separator(),[show(t[i]) | i in index_set(t)]) ++ "}";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

% object member key quoting
function string: quote_key(string: key) =
  if       u_output_format == u_dzn
  then key
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then "\"" ++ key ++ "\""
  else key
  endif;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EXPANSION OF KEY-VALUE PAIRS BASED ON FORMAT AND MZN TYPE
%%% Signatures reflect the various MZN types
%%% Behaviour depends on format choice

%
function string: quote(bool: value) =
  if       u_output_format == u_dzn
  then show(value)
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then json_quote_bool(value)
  else show(value)
  endif;

%
function string: quote(int: value) =
  if       u_output_format == u_dzn
  then show(value)
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then show(value)
  else show(value)
  endif;

%
function string: quote(string: value) =
  if       u_output_format == u_dzn
  then show(value)
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then show(value)
  else  show(value)
  endif;

%
function string: quote(set of int: value) =
  if       u_output_format == u_dzn
  then dzn_quote_set(value)
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then "{\"set\" : " ++ show(set2array(value)) ++ "}"
  else show(value)
  endif;

%
function string: quote(array[int] of bool: value) =
  if       u_output_format == u_dzn
  then "[" ++ join(elements_separator(),[show(value[i]) | i in index_set(value)]) ++ "]"
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then "[" ++ join(elements_separator(),[json_quote_bool(value[i]) | i in index_set(value)]) ++ "]"
  else show(value)
  endif;

%
function string: quote(array[int] of int: value) =
  if       u_output_format == u_dzn
  then "[" ++ join(elements_separator(),[show(value[i]) | i in index_set(value)]) ++ "]"
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then show(value)
  else show(value)
  endif;

%
function string: quote(array[int] of string: value) =
  if       u_output_format == u_dzn
  then "[" ++ join(elements_separator(),[show(value[i]) | i in index_set(value)]) ++ "]"
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then show(value)
  else show(value)
  endif;

%
function string: quote(array[int] of set of int: value) =
  if       u_output_format == u_dzn
  then "[" ++ join(elements_separator(), [dzn_quote_set(value[i]) | i in index_set(value)]) ++"]"
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then "[" ++ join(elements_separator(), ["{\"set\" : " ++ show(set2array(value[i])) ++ "}" | i in index_set(value)]) ++"]"
  else show(value)
  endif;

%
function string: quote(array[int,int] of bool: value) =
  if       u_output_format == u_dzn
  then "[|" ++ join("|",[join(elements_separator(),[show(value[i,j]) | j in index_set_2of2(value)]) |  i in index_set_1of2(value)]) ++ "|]" 
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then "[" ++ join(",",["["++join(elements_separator(),[json_quote_bool(value[i,j]) | j in index_set_2of2(value)])++"]" |  i in index_set_1of2(value)]) ++ "]" 
  else show(value)
  endif;

%
function string: quote(string: key, string: indexset1, string: indexset2, array[int,int] of bool: value) =
  if       u_output_format == u_dzn
  then quote_key(key) ++ key_value_separator() ++ "array2d(" ++ indexset1 ++ "," ++ indexset2 ++ "," ++ "[" ++ join(elements_separator(),[show(value[i,j]) | i in index_set_1of2(value), j in index_set_2of2(value)]) ++ "]" ++ ")"
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then quote_key(key) ++ key_value_separator() ++ "[" ++ join(",",["["++join(elements_separator(),[json_quote_bool(value[i,j]) | j in index_set_2of2(value)])++"]" |  i in index_set_1of2(value)]) ++ "]" 
  else quote_key(key) ++ key_value_separator() ++ show(value)
  endif;

%
function string: quote(array[int,int] of int: value) =
  if       u_output_format == u_dzn
  then "[|" ++ join("|",[join(elements_separator(),[show(value[i,j]) | j in index_set_2of2(value)]) |  i in index_set_1of2(value)]) ++ "|]" 
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then "[" ++ join(elements_separator(),[show(value[i..i,index_set_2of2(value)]) | i in index_set_1of2(value)]) ++ "]"  
  else show(value)
  endif;

%
function string: quote(string: key, string: indexset1, string: indexset2, array[int,int] of int: value) =
  if       u_output_format == u_dzn
  then quote_key(key) ++ key_value_separator() ++ "array2d(" ++ indexset1 ++ "," ++ indexset2 ++ "," ++ "[" ++ join(elements_separator(),[show(value[i,j]) | i in index_set_1of2(value), j in index_set_2of2(value)]) ++ "]" ++ ")"
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then quote_key(key) ++ key_value_separator() ++ "[" ++ join(elements_separator(),[show(value[i..i,index_set_2of2(value)]) | i in index_set_1of2(value)]) ++ "]"  
  else quote_key(key) ++ key_value_separator() ++ show(value)
  endif;

%
function string: quote(array[int,int] of string: value) =
  if       u_output_format == u_dzn
  then "[|" ++ join("|",[join(elements_separator(),[show(value[i,j]) | j in index_set_2of2(value)]) |  i in index_set_1of2(value)]) ++ "|]" 
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then "[" ++ join(elements_separator(),[show(value[i..i,index_set_2of2(value)]) | i in index_set_1of2(value)]) ++ "]"  
  else show(value)
  endif;

%
function string: quote(string: key, string: indexset1, string: indexset2, array[int,int] of string: value) =
  if       u_output_format == u_dzn
  then quote_key(key) ++ key_value_separator() ++ "array2d(" ++ indexset1 ++ "," ++ indexset2 ++ "," ++ "[" ++ join(elements_separator(),[show(value[i,j]) | i in index_set_1of2(value), j in index_set_2of2(value)]) ++ "]" ++ ")"
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then quote_key(key) ++ key_value_separator() ++ "[" ++ join(elements_separator(),[show(value[i..i,index_set_2of2(value)]) | i in index_set_1of2(value)]) ++ "]"  
  else quote_key(key) ++ key_value_separator() ++ show(value)
  endif;

%
function string: quote(array[int,int] of set of int: value) =
  if       u_output_format == u_dzn
  then "[|" ++ join("|",[join(elements_separator(),[dzn_quote_set(value[i,j]) | j in index_set_2of2(value)]) |  i in index_set_1of2(value)]) ++ "|]" 
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then "[" ++ join(elements_separator(),["[" ++ join(elements_separator(),["{\"set\" : " ++ show(set2array(value[i,j])) ++ "}" | j in index_set_2of2(value)]) ++"]" | i in index_set_1of2(value)]) ++ "]"  
  else show(value)
  endif;
  
%
function string: quote(string: key, string: indexset1, string: indexset2, array[int,int] of set of int: value) =
  if       u_output_format == u_dzn
  then quote_key(key) ++ key_value_separator() ++ "array2d(" ++ indexset1 ++ "," ++ indexset2 ++ "," ++ "[" ++ join(elements_separator(),[dzn_quote_set(value[i,j]) | i in index_set_1of2(value), j in index_set_2of2(value)]) ++ "]" ++ ")"
  elseif u_output_format == u_json \/ u_output_format == u_json_mzn
  then quote_key(key) ++ key_value_separator() ++ "[" ++ join(elements_separator(),["[" ++ join(elements_separator(),["{\"set\" : " ++ show(set2array(value[i,j])) ++ "}" | j in index_set_2of2(value)]) ++"]" | i in index_set_1of2(value)]) ++ "]"  
  else quote_key(key) ++ key_value_separator() ++ show(value)
  endif;
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN OUTPUT FUNCTIONS
%%% Active if output switch is on
%%% Signatures reflect the various MZN types
%%% Behaviour depends on input formats

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: value) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(value),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, bool: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, int: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, int: value, array[int] of string: senum, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(senum[value]) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, string: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, set of int: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, set of int: value, array[int] of string: senum, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(senum[value]) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int] of bool: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int] of int: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int] of int: value, array[int] of string: senum, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote([senum[value[i]] | i in index_set(value)]) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int] of string: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int] of set of int: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int,int] of bool: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, string: indexset1, string: indexset2, array[int,int] of bool: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote(key,indexset1,indexset2,value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int,int] of int: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int,int] of int: value, array[int] of string: senum, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(array2d(index_set_1of2(value),index_set_2of2(value),[senum[value[i,j]] | i in index_set_1of2(value), j in index_set_1of2(value)])) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, string: indexset1, string: indexset2, array[int,int] of int: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote(key,indexset1,indexset2,value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, string: indexset1, string: indexset2, array[int,int] of int: value, array[int] of string: senum, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote(key,indexset1,indexset2,array2d(index_set_1of2(value),index_set_2of2(value),[senum[value[i,j]] | i in index_set_1of2(value), j in index_set_1of2(value)])) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int,int] of string: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, string: indexset1, string: indexset2, array[int,int] of string: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote(key,indexset1,indexset2,value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, array[int,int] of set of int: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(trailing_comma),1)
  else 0
  endif;

%
function int: my_output(set of U_OUTPUT_FORMAT: output_formats, string: key, string: indexset1, string: indexset2, array[int,int] of set of int: value, bool: trailing_comma) =
  if u_output==true /\ u_output_format in output_formats
  then trace(newline_indent(0) ++ quote(key,indexset1,indexset2,value) ++ members_separator(trailing_comma),1)
  else 0
  endif;
 