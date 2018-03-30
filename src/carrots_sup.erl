-module(carrots_sup).
-include("../include/m.hrl").
-behaviour(supervisor).

-export([start_link/1, plant/1]).

-export([init/1]).

start_link(Parameters) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Parameters]).

init([Parameters]) ->
    sim_event:notify(ready),
    {ok, {{one_for_one, Parameters#world.carrots, 1}, []}}. 

plant(Parameters) ->
    [supervisor:start_child(?MODULE,
                            single({carrot,E})) || E <- lists:seq(1,Parameters)],
    sim_event:notify(ready).
single(E) ->
    {E,
     {carrot_srv, start_link, [sim_lib:gen_pos(random)]},
     temporary,
     brutal_kill,
     worker,
     [carrot_srv]}.
