-module(nagchamp).
-export([start/0]).

start() -> 
  ok = application:start(syntax_tools),
  ok = application:start(compiler),
  ok = application:start(goldrush),
  ok = application:start(lager),
  ok = application:start(nagchamp).
