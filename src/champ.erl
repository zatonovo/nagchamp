-module(champ).
-behavior(gen_server).

-export([start_job/2, stop_job/1]).
-export([start_link/0, init/1, handle_call/3, handle_cast/2]).
-export([handle_info/2, terminate/2, code_change/3]).

-record(state, {jobs=#{} }).

start_link() -> 
  gen_server:start_link({local,?MODULE}, ?MODULE, [], []).

start_job(Job, Delay) -> 
  gen_server:call(?MODULE, {start, Job, Delay}).

stop_job(JobId) ->
  gen_server:cast(?MODULE, {stop, JobId}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PRIVATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p_seconds({_M,S,U}) ->
  S*1000000 + U.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% GEN_SERVER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init(_Args) ->
  {ok, #state{}}.

handle_cast({stop, JobId}, #state{jobs=OldJobs}=State) ->
  Jobs = try
    TRef = maps:get(JobId, OldJobs),
    timer:cancel(TRef),
    maps:remove(JobId, OldJobs)
  catch _:_ ->
    lager:info("[~p] Unknown job ~p",[?MODULE,JobId]),
    OldJobs
  end,
  {noreply, State#state{jobs=Jobs}}.

handle_call({start,Url,Delay}, _From, #state{jobs=OldJobs}=State) ->
  JobId = integer_to_binary(p_seconds(now())),
  TRef = pinger:make_request(Url, Delay),
  Jobs = maps:put(JobId,TRef, OldJobs),
  {reply, JobId, State#state{jobs=Jobs} }.

handle_info(_Info, State) ->
  {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.

