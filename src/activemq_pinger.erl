-module(activemq_pinger).
-export([make_request/2, ping/2]).

make_request(Url, Delay) ->
  lager:info("[~p] Sending message to ~p", [self(), Url]),
  [Host,BPort,Queue] = string:tokens(Url,":/"),
  Fun = fun(Payload) ->
    lager:debug("Payload: ~p",[Payload]),
    case proplists:get_value(type,Payload) of
      "CONNECTED" ->
        lager:info("Connected to ~p",[Queue]);
      _ ->
	{_M,S,U} = now(),
	Now = S * 1000000 + U,
	Then = list_to_integer(proplists:get_value(body,Payload)),
	lager:info("Latency: ~p us", [Now - Then])
    end
  end,
  Port = list_to_integer(BPort),
  {ok, Pid} = stomp_client:start(Host, Port,"","",Fun),
  stomp_client:subscribe_queue(Queue, [], Pid),
  timer:apply_interval(Delay, ?MODULE, ping, [Queue, Pid]).

ping(Queue, Pid) ->
  {_M,S,U} = now(),
  Payload = integer_to_list(S * 1000000 + U),
  stomp_client:send_queue(Queue, Payload, [], Pid).

