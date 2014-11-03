-module(champ).
-behavior(gen_server).

-export([start_job/3, stop_job/1, list/0]).
-export([start_link/0, init/1, handle_call/3, handle_cast/2]).
-export([handle_info/2, terminate/2, code_change/3]).

-record(state, {jobs=#{}, handlers}).

start_link() -> 
  gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

%% champ:start_job("http://google.com", 500, url).
%% Type: url | activemq
start_job(Job, Delay, Type) -> 
  gen_server:call(?MODULE, {start, Job, Delay, Type}).

stop_job(JobId) ->
  gen_server:cast(?MODULE, {stop, JobId}).

list() ->
  gen_server:call(?MODULE, list).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRIVATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p_seconds({_M,S,U}) ->
  S*1000000 + U.

init_table() ->
  ets:new(timings, [bag, public, named_table]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GEN_SERVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init(_Args) ->
  init_table(),
  %% Week 10: define an API for pinging different types of services
  Handlers = #{ url => url_pinger, activemq => activemq_pinger },
  {ok, #state{handlers=Handlers}}.

handle_cast({stop, JobId}, #state{jobs=OldJobs}=State) ->
  lager:info("[~p] Stopping job ~p",[?MODULE,JobId]),
  Jobs = try
    TRef = maps:get(JobId, OldJobs),
    timer:cancel(TRef),
    maps:remove(JobId, OldJobs)
  catch _:_ ->
    lager:info("[~p] Unknown job ~p",[?MODULE,JobId]),
    OldJobs
  end,
  {noreply, State#state{jobs=Jobs}}.

%% TODO: Store jobs locally for display purposes
handle_call({start,Url,Delay, Type}, _From, #state{jobs=OldJobs}=State) ->
  lager:info("[~p] Starting ~p job for ~p every ~p ms",
    [?MODULE,Type,Url,Delay]),
  JobId = integer_to_binary(p_seconds(now())),
  Module = maps:get(Type, State#state.handlers),
  {ok,TRef} = Module:make_request(Url, Delay),
  Jobs = maps:put(JobId,TRef, OldJobs),
  {reply, JobId, State#state{jobs=Jobs} };

handle_call(list, _From, #state{jobs=Jobs}=State) ->
  Keys = maps:keys(Jobs),
  {reply, Keys, State}.

handle_info(_Info, State) ->
  {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.

