-module(sim_event).
-export([start_link/1, notify/1]).
 
start_link(Parameters) ->
{ok, Pid} = gen_event:start_link(),
gen_event:add_handler(Pid, sim_handler, [Parameters]),
register(event_handler,Pid),
{ok, Pid}.
 
notify(Event) ->
    io:format("~p~n",[notification]),    
    gen_event:notify(event_handler, Event).
 
