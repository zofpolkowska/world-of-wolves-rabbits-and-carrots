-module(sim_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->

    Flags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},

    World = #{id => world_sup,
               start => {world_sup, start_link, []},
               restart => permanent,
               shutdown => brutal_kill,
               type => supervisor,
               modules => [world_sup]},
    %Controllers = #{id => ctrl,
    %           start => {ctrl, start_link, []},
    %           restart => permanent,
    %           shutdown => brutal_kill,
    %           type => worker,
    %           modules => [ctrl]},

    {ok, {Flags, [World]}}.


%%====================================================================
%% Internal functions
%%====================================================================
