-module(wolf_statem).
-include("../include/m.hrl").
-behaviour(gen_statem).

-export([start_link/1, start_link/2]).
-export([callback_mode/0, init/1, terminate/3, code_change/4]).
-export([state_name/3, running/3, chasing/3, eating/3, splitting/3]).

start_link(Position) ->
    gen_statem:start_link(?MODULE, [Position], []).

start_link(Position, Direction) ->
    gen_statem:start_link(?MODULE, [Position, Direction], []).

callback_mode() -> state_functions.


init([Position]) ->
    Wolf = #wolf{ pid = self(),
                  position = Position,
                  direction = sim_lib:gen_dir(random),
                  belly = ?HUNGRY},
    {ok, running, Wolf, [{state_timeout,?HOP,run}]};

init([Position, Direction]) ->
    Wolf = #wolf{ pid = self(),
                  position = Position,
                  direction = Direction,
                  belly = ?HUNGRY},
     {ok, running, Wolf, [{state_timeout,?HOP,run}]}.


running(state_timeout, run, Wolf)->
    if
        Wolf#wolf.no_food > ?MAX_NO_FOOD ->
            wolves_sup:kill(Wolf);
        true ->
            Time = Wolf#wolf.no_food + ?HOP,
            WolfPos = Wolf#wolf.position,
            try hunt(Wolf#wolf.position) of
                Rabbit ->
                    {next_state, chasing, Wolf#wolf{target = Rabbit, no_food = 0}, 
                     [{state_timeout,?HOP,chase}]}
            catch
                _ ->
                    {next_state, running, 
                     Wolf#wolf{no_food = Time,
                               position = sim_lib:next_pos(WolfPos, Wolf#wolf.direction)}, 
                     [{state_timeout,?HOP,running}]};
                exit:_Exit ->
                    {next_state, running, 
                     Wolf#wolf{no_food = Time,
                               position = sim_lib:next_pos(WolfPos,Wolf#wolf.direction)}, 
                     [{state_timeout,?HOP,run}]};
                error:_Error ->
                    {next_state, running,
                     Wolf#wolf{no_food = Time,
                               position = sim_lib:next_pos(WolfPos,Wolf#wolf.direction)}, 
                     [{state_timeout,?HOP,run}]}
            end
    end.


chasing(state_timeout, chase, Wolf) ->
    WolfPos = Wolf#wolf.position,
    TargetPos = gen_statem:call(Wolf#wolf.target,position),
    Direction = sim_lib:chase_direction(TargetPos, WolfPos),
    try gen_statem:call(Wolf#wolf.target, {hunt, WolfPos}) of
        true ->
            {next_state, eating, Wolf, [{state_timeout, ?HOP, eat}]}
    catch
        exit:_Exit ->
            {next_state, running, 
             Wolf#wolf{direction = Direction,
                       position = sim_lib:next_pos(WolfPos,Direction)}, 
                         [{state_timeout,?HOP,chase}]};
        _ ->
            {next_state, chasing, 
             Wolf#wolf{direction = Direction,
                       position = sim_lib:next_pos(WolfPos,Direction)}, 
                         [{state_timeout,?HOP,chase}]}
    end.

eating(state_timeout, eat, Wolf) ->
    Belly = Wolf#wolf.belly+1,
    try gen_statem:stop(Wolf#wolf.target) of
        _ ->
            case Belly of
                ?FULL_WOLF ->
              {next_state, splitting, Wolf#wolf{belly=Belly, target=undefined}, 
               [{state_timeout,?HOP,split}]};
                _ ->
              {next_state, running, Wolf#wolf{belly=Belly, target=undefined}, 
               [{state_timeout,?HOP,run}]}
            end
    catch
        _ ->
            {next_state, running, Wolf#wolf{target=undefined}, 
             [{state_timeout,?HOP,run}]};
        exit:_Exit ->
              {next_state, running, Wolf#wolf{target=undefined}, 
               [{state_timeout,?HOP,run}]};
        error:_Error ->
              {next_state, running, Wolf#wolf{belly=Belly+1, target=undefined}, 
               [{state_timeout,?HOP,run}]}
    end.

splitting(state_timeout, split, Wolf) ->
    wolves_sup:split(Wolf),
    D = sim_lib:turn(Wolf#wolf.direction),
    {next_state, running, Wolf#wolf{direction = D}, [{state_timeout,?HOP,run}]}.

state_name({call,Caller}, _Msg, Wolf) ->
    {next_state, state_name, Wolf, [{reply,Caller,ok}]}.

terminate(_Reason, _State, _Data) ->
    void.

code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

hunt(Position) ->
    hunt(Position,
         [Pid|| {_,Pid,_,_} <- supervisor:which_children(rabbits_sup)]).

hunt(_, []) ->
    throw(failure);
hunt(Position, [H|T]) ->
    try gen_statem:call(H,{distance, Position}) of
        true ->
            H;
        false ->
            hunt(Position, T)
    catch
        _ ->
             throw(failure)
    end.


