-module(set).
-include("../include/m.hrl").

-export([world/0, carrots/0]).

world() ->
    #world{carrots = application:get_env(sim, carrots, 25),
           rabbits = application:get_env(sim, rabbits, 7),
           wolves = application:get_env(sim, wolves, 3),
           width = application:get_env(sim, width, 5),
           height  = application:get_env(sim, height, 5)}.

carrots() ->
    application:get_env(sim, carrots, 12).
