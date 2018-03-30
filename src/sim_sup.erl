-module(sim_sup).
-include("../include/m.hrl").
-behaviour(supervisor).

-export([start_link/1]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link(Parameters) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Parameters]).

init([Parameters]) ->

    Flags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},

    World = #{id => world_sup,
               start => {world_sup, start_link, [Parameters]},
               restart => permanent,
               shutdown => brutal_kill,
               type => supervisor,
               modules => [world_sup]},
    Controller = #{id => sim_event,
               start => {sim_event, start_link, [Parameters]},
               restart => permanent,
               shutdown => brutal_kill,
               type => worker,
               modules => [sim_event]},

    {ok, {Flags, [Controller,World]}}.


%%====================================================================
%% Internal functions
%%====================================================================


