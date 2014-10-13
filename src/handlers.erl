-module(handlers).
-export([format_csv/1, format_json/1]).

% Version 1: Concatenate string
% Version 2: Accumulate in a list and then join
format_csv(init) ->
  "url,timestamp,duration";

format_csv({row,Row,Data}) ->
  Data ++ "\n" ++ element(1,Row) ++ "," ++ element(2,Row) ++ "," ++ integer_to_list(element(3,Row));

format_csv({finish,Data}) ->
  Data.


format_json(init) ->
  "{'data':[";

format_json({row,Row,Data}) ->
  {M,S,_U} = element(2,Row),
  Secs = integer_to_list(1000000 * M + S),
  Data ++ "'" ++ element(1,Row) ++ "'," ++ Secs ++ "," ++ integer_to_list(element(3,Row)) ++ ",";

format_json({finish,Data}) ->
  string:strip(Data,right,$,) ++ "]}".
