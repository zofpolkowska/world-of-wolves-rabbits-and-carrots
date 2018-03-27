-module(set).
-include("../include/m.hrl").

-export([world/0, carrots/0]).

world() ->
    #world{carrots = application:get_env(sim, carrots, 12),
           rabbits = application:get_env(sim, rabbits, 4),
           wolves = application:get_env(sim, wolves, 0),
           width = application:get_env(sim, width, 4),
           height  = application:get_env(sim, height, 4)}.

carrots() ->
    application:get_env(sim, carrots, 12).
