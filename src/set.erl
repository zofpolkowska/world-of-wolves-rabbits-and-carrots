-module(set).
-include("../include/m.hrl").

-export([world/0]).

world() ->
    #world{carrots = 5, %application:get_env(sim, carrots, 12),
           rabbits = 1, %application:get_env(sim, rabbits, 4),
           wolves = 0, %application:get_env(sim, wolves, 2),
           width = 2, %application:get_env(sim, width, 4),
           height  = 2}. %application:get_env(sim, height, 4)}.
