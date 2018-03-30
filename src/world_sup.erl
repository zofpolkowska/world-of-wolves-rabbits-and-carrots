-module(world_sup).
-include("../include/m.hrl").
-behaviour(supervisor).

-export([start_link/1]).
-export([init/1]).
-export([populate/1]).

start_link(Parameters) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Parameters]).

init([Parameters]) ->

    Flags = #{strategy => one_for_one,
                 intensity => 1,
                 period => 5},
    Carrots = #{id => carrots_sup,
               start => {carrots_sup, start_link, [Parameters]},
               restart => permanent,
               shutdown => brutal_kill,
               type => supervisor,
               modules => [carrotss_sup]},
    Rabbits = #{id => rabbits_sup,
               start => {rabbits_sup, start_link, [Parameters]},
               restart => permanent,
               shutdown => brutal_kill,
               type => supervisor,
               modules => [rabbits_sup]},
    Wolves = #{id => wolves_sup,
               start => {wolves_sup, start_link, [Parameters]},
               restart => permanent,
               shutdown => brutal_kill,
               type => supervisor,
               modules => [wolves_sup]},
    {ok, {Flags, [Carrots,Rabbits,Wolves]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

populate(Parameters) ->
    {carrots_sup:plant(Parameters#world.carrots), 
     rabbits_sup:breed(Parameters#world.rabbits),
     wolves_sup:breed(Parameters#world.wolves)}.
