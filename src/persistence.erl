-module(persistence).

-export([put/3, get/1]).

put(Url, Time, Duration) ->
  % try
      ets:insert(timings, {Url, Time, Duration}).
	% catch 
      
get(Url) ->
   ets:lookup(timings, Url).	
