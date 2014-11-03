-module(activemq_pinger).
-export([make_request/2, ping/1]).

make_request(Url, Delay) ->
  lager:info("[~p] Sending message to ~p", [self(), Url]),
  [Host,Port,Topic] = binary:split(Url, [<<":">>, <<"/">>], [global]),
  Fun = fun(Msg) ->
      lager:info("~p", Msg)
  end,
  {ok, Pid} = stomp_client:start(binary_to_list(Host), binary_to_integer(Port),"","",Fun),
  stomp_client:subscribe_topic(binary_to_list(Topic), [], Pid),
  timer:apply_interval(Delay, ?MODULE, ping, [binary_to_list(Topic), Pid]).

ping(Topic, Pid) ->
  stomp_client:send_topic(Topic, "ping!", [], Pid).

