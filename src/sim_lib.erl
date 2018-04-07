-module(sim_lib).
-include("../include/m.hrl").
-export([gen_pos/1,equal/2, gen_dir/1, directions/0, next_pos/2, turn/1, distance/2, chase_direction/2]).

gen_pos(random) ->
    Param = set:world(),
    {Width, Height} = {Param#world.width, Param#world.height},
    {X,Y} = {rand:uniform(Width),rand:uniform(Height)},
    #pos{x = X,y = Y};
gen_pos({X,Y}) ->
    #pos{x = X,y = Y}.

equal(Position1, Position2) ->
    (Position1#pos.x == Position2#pos.x) and (Position1#pos.y == Position2#pos.y).

distance(Position1, Position2) ->
    math:sqrt(math:pow((Position1#pos.x - Position2#pos.x),2) + math:pow((Position1#pos.y == Position2#pos.y),2)).
directions() ->
    {n,s,w,e,ne,nw,se,sw}.
gen_dir(random) ->
    element(rand:uniform(7)+1, directions()).

chase_direction(TargetPosition, WolfPosition) ->
    Tx = TargetPosition#pos.x,
    Ty = TargetPosition#pos.y,
    Wx = WolfPosition#pos.x,
    Wy = WolfPosition#pos.y,
    case (Ty < Wy) of
        true ->
            NS = "n";
        false ->
            NS = "s"
    end,
    case (Tx < Wx) of
        true ->
            WE = "w";
        false ->
            WE = "e"
    end,
    list_to_atom(NS++WE).
turn(n) ->
    s;
turn(s) ->
    n;
turn(w) ->
    e;
turn(e) ->
    w;
turn(nw) ->
    se;
turn(ne) ->
    sw;
turn(sw) ->
    ne;
turn(se) ->
    nw.
next_pos(Position, Direction) ->
    {X,Y} = {Position#pos.x, Position#pos.y},
    Param = set:world(),
    {Width, Height} = {Param#world.width,Param#world.height},
    case Direction of
        n ->
            #pos{x = X,y = max(0,Y - 1)};
        s ->
            #pos{x = X,y = min(Y + 1,Height)};
        w ->
            #pos{x = max(0,X - 1),y = Y};
        e ->
            #pos{x = min(X + 1,Width),y = Y};
        nw ->
            #pos{x = max(0,X - 1),y = max(0,Y - 1)};
        ne ->
            #pos{x = min(X + 1,Width),y = max(0,Y - 1)};
        sw ->
            #pos{x = max(0,X - 1),y = min(Y + 1,Height)};
        se ->
            #pos{x = min(X + 1,Width),y = min(Y + 1,Height)};
        _ ->
            Position
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
