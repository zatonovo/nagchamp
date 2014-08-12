-module(axiom_handler).

-export([start/1]).
-export([handle/3]).

start(Args) ->
  axiom:start(?MODULE, Args).

handle(<<"GET">>, [], Request) ->
  "ok".
