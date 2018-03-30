-module(set).
-include("../include/m.hrl").

-export([world/0, carrots/0]).

world() ->
    #world{carrots = application:get_env(sim, carrots, 14),
           rabbits = application:get_env(sim, rabbits, 3),
           wolves = application:get_env(sim, wolves, 1),
           width = application:get_env(sim, width, 4),
           height  = application:get_env(sim, height, 4)}.

carrots() ->
    application:get_env(sim, carrots, 12).
