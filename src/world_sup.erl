-module(world_sup).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).
-export([populate/0]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->

    Flags = #{strategy => one_for_one,
                 intensity => 1,
                 period => 5},
    Carrots = #{id => carrots_sup,
               start => {carrots_sup, start_link, []},
               restart => permanent,
               shutdown => brutal_kill,
               type => supervisor,
               modules => [carrotss_sup]},
    Rabbits = #{id => rabbits_sup,
               start => {rabbits_sup, start_link, []},
               restart => permanent,
               shutdown => brutal_kill,
               type => supervisor,
               modules => [rabbits_sup]},
    Wolves = #{id => wolves_sup,
               start => {wolves_sup, start_link, []},
               restart => permanent,
               shutdown => brutal_kill,
               type => supervisor,
               modules => [wolves_sup]},
    {ok, {Flags, [Carrots,Rabbits,Wolves]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

populate() ->
    {carrots_sup:plant(), rabbits_sup:breed(), wolves_sup:breed()}.
