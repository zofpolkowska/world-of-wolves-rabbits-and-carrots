-module(rabbits_sup).
-include("../include/m.hrl").

-behaviour(supervisor).

-export([start_link/1]).
-export([init/1]).
-export([breed/1,last/0,split/1, kill/1]).


start_link(Parameters) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Parameters]).

init([Parameters]) ->
    sim_event:notify(ready),
    {ok, {{one_for_one, Parameters#world.rabbits, 1}, []}}.

%%%===================================================================%%%
breed(Parameters) ->
    [supervisor:start_child(?MODULE,
                            single({rabbit,E})) || E <- lists:seq(1,Parameters)],
    sim_event:notify(ready).
single(E) ->
    {E,
     {rabbit_statem, start_link, [sim_lib:gen_pos(random)]},
     temporary,
     brutal_kill,
     worker,
     [rabbit_statem]}.

last() ->
    Ids = [Id || {{rabbit,Id},_,_,_} <- supervisor:which_children(?MODULE)],
    lists:foldl(fun (X,Max) -> if X > Max -> X;
                                  true -> Max end end, 0, Ids).
split(Rabbit) ->
    D = Rabbit#rabbit.direction,
    P = sim_lib:next_pos(Rabbit#rabbit.position, D),
    supervisor:start_child(?MODULE,
                           {last()+1,
                            {rabbit_statem, start_link, [P,D]},
                            temporary,
                            brutal_kill,
                            worker,
                            [rabbit_statem]}).
    
kill(Rabbit) ->
    gen_statem:stop(Rabbit#rabbit.pid).
