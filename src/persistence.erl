-module(persistence).

-export([put/3, get/1, export/1, export/2]).
-define(TID, timings).

put(Url, Time, Duration) ->
  % try
      ets:insert(timings, {Url, Time, Duration}).
	% catch 
      
get(Url) ->
   ets:lookup(timings, Url).	


export(Handler) ->
  Out1 = Handler(init),
  Out2 = ets:foldl(fun(Row,Acc) -> Handler({row,Row,Acc}) end, Out1, ?TID),
  Handler({finish,Out2}).


export(Handler, Filename) ->
  Out = export(Handler),
  file:write_file(Filename,Out).
