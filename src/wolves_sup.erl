-module(wolves_sup).
-include("../include/m.hrl").

-behaviour(supervisor).

-export([start_link/1]).
-export([init/1]).
-export([breed/1]).

start_link(Parameters) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Parameters]).

init([Parameters]) ->
        sim_event:notify(ready),
    Flags = #{strategy => one_for_one,
                 intensity => Parameters#world.wolves,
                 period => 1},

    {ok, {Flags, []}}.
%%%===================================================================%%%
breed(Parameters) ->
    [supervisor:start_child(?MODULE,
                            single({wolf,E})) || E <- lists:seq(1,Parameters)].

single(E) ->
    {E,
     {wolf_statem, start_link, [sim_lib:gen_pos(random)]},
     temporary,
     brutal_kill,
     worker,
     [wolf_statem]}.

last() ->
    Ids = [Id || {{wolf,Id},_,_,_} <- supervisor:which_children(?MODULE)],
    lists:foldl(fun (X,Max) -> if X > Max -> X;
                                  true -> Max end end, 0, Ids).


