-module(nagchamp_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  nagchamp_sup:start_link(),
  UrlList = case os:getenv("NAGCHAMP_TARGETS") of
    false -> ["http://me-meme.com"];
    L -> L
  end,
  Delay = case os:getenv("NAGCHAMP_DELAY") of
    false -> 60000;
    V -> V
  end,
  [ champ:start_job(Url, Delay) || Url <- UrlList ].

stop(_State) ->
    ok.
