-module(nagchamp).
-export([start/0]).

start() -> 
  application:set_env(lager, error_logger_hwm, 200, [{persistent,true}]),
  ok = application:start(syntax_tools),
  ok = application:start(compiler),
  ok = application:start(goldrush),
  ok = application:start(lager),
  ok = application:start(crypto),
  ok = application:start(ranch),
  ok = application:start(cowboy),
  ok = application:start(inets),
  ok = application:start(nagchamp).
