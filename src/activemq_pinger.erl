-module(activemq_pinger).
-export([make_request/2, ping/2]).

make_request(Url, Delay) ->
  lager:info("[~p] Sending message to ~p", [self(), Url]),
  [Host,BPort,Queue] = binary:split(Url, [<<":">>, <<"/">>], [global]),
  Fun = fun(Payload) ->
      {_M,S,U} = now(),
      Now = S * 1000000 + U,
      Then = list_to_integer(Payload),
      lager:info("Latency: ~p", Now - Then)
  end,
  Port = binary_to_integer(BPort),
  {ok, Pid} = stomp_client:start(binary_to_list(Host), Port,"","",Fun),
  stomp_client:subscribe_queue(binary_to_list(Queue), [], Pid),
  timer:apply_interval(Delay, ?MODULE, ping, [binary_to_list(Queue), Pid]).

ping(Queue, Pid) ->
  {_M,S,U} = now(),
  Payload = integer_to_list(S * 1000000 + U),
  stomp_client:send_queue(Queue, Payload, [], Pid).

