-module(carrots_sup).
-include("../include/m.hrl").
-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-export([plant/0, children/0]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Param = set:world(),
    Flags = #{strategy => one_for_one,
                 intensity => Param#world.carrots,
                 period => 1},

    {ok, {Flags, []}}.

%%%===================================================================%%%

plant() ->
    Param = set:world(),
    [carrot(Counter) || Counter <- lists:seq(1,Param#world.carrots)].

carrot(Counter) ->
   Carrot =  #{id => {carrot,Counter},
               start => {carrot_srv, start_link, []},
               restart => temporary,
               shutdown => brutal_kill,
               type => worker,
               modules => [carrot_srv]},
    {ok,Pid} = supervisor:start_child(?MODULE, Carrot),
    Pid.

children() ->
    Ans = supervisor:which_children(?MODULE),
    [Pid || {_,Pid,_,_} <- Ans].

