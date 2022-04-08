%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOGGING

include "output.mzn";


% variable globale de logging
set of int: u_log;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FONCTIONS DE LOGGING
%
function int: my_trace(int: log_flag, string: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(value),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, bool: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, int: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, int: value, array[int] of string: senum) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(senum[value]) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, string: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, set of int: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, set of int: value, array[int] of string: senum) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(senum[value]) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int] of bool: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int] of int: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int] of int: value, array[int] of string: senum) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote([senum[value[i]] | i in index_set(value)]) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int] of string: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int] of set of int: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int,int] of bool: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, string: indexset1, string: indexset2, array[int,int] of bool: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote(key,indexset1,indexset2,value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int,int] of int: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int,int] of int: value, array[int] of string: senum) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(array2d(index_set_1of2(value),index_set_2of2(value),[senum[value[i,j]] | i in index_set_1of2(value), j in index_set_1of2(value)])) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, string: indexset1, string: indexset2, array[int,int] of int: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote(key,indexset1,indexset2,value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, string: indexset1, string: indexset2, array[int,int] of int: value, array[int] of string: senum) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote(key,indexset1,indexset2,array2d(index_set_1of2(value),index_set_2of2(value),[senum[value[i,j]] | i in index_set_1of2(value), j in index_set_1of2(value)])) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int,int] of string: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, string: indexset1, string: indexset2, array[int,int] of string: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote(key,indexset1,indexset2,value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, array[int,int] of set of int: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote_key(key) ++ key_value_separator() ++ quote(value) ++ members_separator(false),1)
  else 0
  endif;

%
function int: my_trace(int: log_flag, string: key, string: indexset1, string: indexset2, array[int,int] of set of int: value) =
  if log_flag in u_log
  then trace(newline_indent(log_flag) ++ quote(key,indexset1,indexset2,value) ++ members_separator(false),1)
  else 0
  endif;
