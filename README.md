nagchamp
========

An erlang process that pings heroku apps or other servers


Week 6 ETS
{Url, TimeStamp, Duration}
ets:new(Table, {bag, {keypos,1}, public})
persistence:get(Url) ->
  [Tuple] = ets:lookup(timings, Url)

persistence:put(Url, TimeStamp, Duration) ->
  ets:insert(timings, {Url, TimeStamp, Duration}).

Change to a set
---------------
Performance issues since linear scan
ets:new(Table, {set, {keypos,2}, public})
Can't use lookup to get a single element

```
persistence:get(Url) ->
  [[Tuple]] = ets:match(timings, Url)
```

How can you get better performance?

Emulate a bag
-------------
ets:new(Table, {set, {keypos,1}, public})
{Url, [{TimeStamp, Duration}] }

```
persistence:get(Url) ->
  [{_Url, List}] = ets:lookup(timings, Url),
  List.
```
Alternatively,
```
persistence:get(Url) ->
  ets:lookup_element(timings, Url, 2).
```

persistence:put(Url, TimeStamp, Duration) ->
  
  ets:insert(timings, {Url, TimeStamp, Duration}).
```


Ring buffer
-----------
timings:
{Url, {TS1,D1}, {TS2,D2}, ..., {TSN,DN}}

ringbuffer:
{Name, N}

persistence:get(Url) ->
  N = persistence:get(ringbuffer, Name),
  BigTuple = ets:lookup(Url)
  % Construct based on N as the pivot

persistence:put(Url, TimeStamp, Duration) ->
  N = persistence:get(ringbuffer, Name),
  ets:update_element(timings, Url, {Ts,D}, N+1),
  ets:update_element(ringbuffer, Name, N+1, 2),
  case N == Limit of
    true ->
    _ ->
  end.

Week 8
======
+ Implement format handlers
+ Write out to file

persistence:export(Filename, Handler)

persistence:export(Handler)


Week 9
======
+ Add GUI

Week 10
=======
+ Update champ:list() to return more details of job
+ Add handler to initiate different types of jobs (e.g. erlstomp for ActiveMQ)

Modify champ to include a Type argument to start_job. The allowed types
are url and activemq. Add a lookup table to champ to manage the modules
available for each ping type. In our case, this is 
```
Handlers = #{ url => url_pinger, activemq => activemq_pinger }
```

The original pinger.erl needs to be moved to url_pinger.erl and then
the handle_call({start, ...}, ...) job updated to use the lookup table.

