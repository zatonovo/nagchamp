-module(pinger).
-export([make_request/2, ping/1]).

% Rate: Frequency e.g. 2 => 2 per second
% Delay in ms
make_request(Url, Delay) ->
  %Time = round(1000 / Rate),
  timer:apply_interval(Delay, pinger, ping, [Url]).


ping(Url) ->
  lager:info("[~p] Sending request to ~p", [self(), Url]),
  try
    Now = now(),
    {Time, _} = timer:tc(httpc, request, [Url]),
    persistence:put(Url, Now, Time)
  catch _:Error ->
    lager:warning("[~p] Unexpected response: ~p", [self(), Error])
  end.
