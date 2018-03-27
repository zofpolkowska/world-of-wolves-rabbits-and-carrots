-module(rabbits_sup).
-include("../include/m.hrl").

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-export([breed/0]).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Param = set:world(),
    Flags = #{strategy => one_for_one,
                 intensity => Param#world.rabbits,
                 period => 1},

    {ok, {Flags, []}}.

%%%===================================================================%%%
breed() ->
    Param = set:world(),
    [rabbit(Counter) || Counter <- lists:seq(1,Param#world.rabbits)].

rabbit(Counter) ->
   Rabbit =  #{id => {rabbit,Counter},
               start => {rabbit_statem, start_link, []},
               restart => temporary,
               shutdown => brutal_kill,
               type => worker,
               modules => [rabbit_statem]},
    {ok,Pid} = supervisor:start_child(?MODULE, Rabbit),
    Pid.





