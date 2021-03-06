-module(axiom_handler).

-export([start/1]).
-export([handle/3]).

start(Args) ->
  axiom:start(?MODULE, Args).

handle(<<"GET">>, [], Request) ->
  lager:info("[~p] Ping",[?MODULE]),
  axiom:dtl(main, [{name,<<"brian">>}]);

handle(<<"GET">>, [<<"ping">>], Request) ->
  {_M,S,U} = now(),
  Now = integer_to_binary(S*1000000 + U),
  <<"[",Now/binary,"] pong">>;

handle(<<"GET">>, [<<"rest">>, <<"jobs">>], Request) ->
  champ:list();

handle(<<"GET">>, [<<"rest">>, <<"job">>, Url, Delay], Request) ->
  StringUrl = binary_to_list(<<"http://", Url/binary>>),
  champ:start_job(StringUrl, binary_to_integer(Delay)),
  "ok";

handle(<<"GET">>, [<<"rest">>, <<"job">>, JobId], Request) ->
  champ:stop_job(JobId),
  "ok".
