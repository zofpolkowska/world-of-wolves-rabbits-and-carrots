-module(rabbit_statem).
-include("../include/m.hrl").

-behaviour(gen_statem).

-export([start_link/1, start_link/2]).
-export([callback_mode/0, init/1, terminate/3, code_change/4]).
-export([state_name/3,jumping/3, eating/3, splitting/3, handle_event/3]).

-export([find/1]).
start_link(Position) ->
    gen_statem:start_link(?MODULE, [Position], []).

start_link(Position, Direction) ->
    gen_statem:start_link(?MODULE, [Position, Direction], []).

callback_mode() -> state_functions.


init([Position]) ->
    Rabbit = #rabbit{ pid = self(),
                      position = Position,
                      direction = sim_lib:gen_dir(random),
                      belly = ?HUNGRY },
    {ok, jumping, Rabbit, [{state_timeout,?JUMP,jump}]};

init([Position, Direction]) ->
    Rabbit = #rabbit{ pid = self(),
                      position = Position,
                      direction = Direction,
                      belly = ?HUNGRY },
    {ok, jumping, Rabbit, [{state_timeout,?JUMP,jump}]}.



handle_event({call,From}, {distance, Position}, Rabbit) ->
    Dist = sim_lib:distance(Position, Rabbit#rabbit.position),
    if 
        (Dist < ?NOSE) ->
            {keep_state,Rabbit,[{reply,From, true}]};
        true ->           
            {keep_state,Rabbit,[{reply,From, false}]}
    end;

handle_event({call,From}, {hunt, Position}, Rabbit) ->
    case sim_lib:equal(Position,Rabbit#rabbit.position) of
        true ->
            {keep_state,Rabbit,[{reply,From,true}]};
        _ ->
            {keep_state,Rabbit,[{reply,From,throw(false)}]}
    end;

handle_event({call,From}, position, Rabbit) ->
    Reply = Rabbit#rabbit.position,
    {keep_state,Rabbit,[{reply,From,Reply}]}.

jumping(state_timeout, jump,  Rabbit) ->
    Time = Rabbit#rabbit.no_food + ?JUMP,
    if
        Time > ?MAX_NO_FOOD ->
            rabbits_sup:kill(Rabbit);
        true ->
            io:format("~p~n",[jumping]),
            try find(Rabbit#rabbit.position) of
                Carrot ->
                    {next_state, eating, 
                     Rabbit#rabbit{carrot = Carrot, no_food = 0}, 
                     [{state_timeout,500,eat}]}
            catch
                exit:_Exit ->
                    NPos = sim_lib:next_pos(Rabbit#rabbit.position,Rabbit#rabbit.direction),
                    {next_state, jumping,Rabbit#rabbit{position = NPos, no_food = Time}, 
                     [{state_timeout,500,jump}]};
                _ ->
                    NPos = sim_lib:next_pos(Rabbit#rabbit.position,Rabbit#rabbit.direction),
                    case sim_lib:equal(Rabbit#rabbit.position, NPos) of
                        true ->
                            NewDir = sim_lib:turn(Rabbit#rabbit.direction),
                            {next_state, jumping, 
                             Rabbit#rabbit{position = NPos, direction = NewDir,
                                           no_food = Time}, 
                             [{state_timeout,500,jump}]};
                        _ ->
                            {next_state, jumping,
                             Rabbit#rabbit{no_food = Time,position = NPos}, 
                             [{state_timeout,500,jump}]}
                    end
            end
    end;

jumping({call,Caller}, _Msg, Rabbit) ->
    {next_state, state_name, Rabbit, [{reply,Caller,ok}]}.

eating(state_timeout, eat, Rabbit) ->
        try gen_server:call(Rabbit#rabbit.carrot,bite) of
            E ->
        io:format("~p ~"++erlang:integer_to_list(E+1)++"c~n",[eating,$>]),
                {next_state, eating, Rabbit,[{state_timeout,500,eat}]}
        catch
            exit:_Exit ->
                Belly = Rabbit#rabbit.belly + ?CARROT,
                case Belly of 
                    ?FULL_RABBIT ->
                        {next_state, splitting, 
                         Rabbit#rabbit{belly = Belly, carrot = no},
                         [{state_timeout,?SPLIT,split}]};
                    _ ->
                        {next_state, jumping, 
                         Rabbit#rabbit{belly = Belly, carrot = no}, 
                         [{state_timeout,?JUMP,jump}]}
                end;
            _ ->
                {next_state, jumping, Rabbit, [{state_timeout,?JUMP,jump}]}  

        end.

splitting(state_timeout, split, Rabbit) ->
    rabbits_sup:split(Rabbit),
    D = sim_lib:turn(Rabbit#rabbit.direction),
    {next_state, jumping, Rabbit#rabbit{direction = D}, [{state_timeout,?JUMP,jump}]}.
state_name({call,Caller}, _Msg, Rabbit) ->
    {next_state, state_name, Rabbit, [{reply,Caller,ok}]}.

terminate(_Reason, _State, _Data) ->
    dead.

code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

find(Position) ->
    find(Position, 
         [Pid|| {_,Pid,_,_} <- supervisor:which_children(carrots_sup)]).
find(_, []) ->
    throw(failure);
find(Position,[Head|Rest]) ->
    try sim_lib:equal(gen_server:call(Head, position),Position) of
        true ->
            Head;
        _ ->
            find(Position, Rest)
    catch
        _ -> throw(failure)
    end.
            
