-module(rabbit_statem).
-include("../include/m.hrl").

-behaviour(gen_statem).

-export([start_link/1]).
-export([callback_mode/0, init/1, terminate/3, code_change/4]).
-export([state_name/3,jumping/3, eating/3, splitting/3]).

-export([find/1]).
start_link(Position) ->
    gen_statem:start_link(?MODULE, [Position], []).

callback_mode() -> state_functions.


init([Position]) ->
    Rabbit = #rabbit{ pid = self(),
                      position = Position,
                      direction = sim_lib:gen_dir(random)},
    {ok, jumping, Rabbit, [{state_timeout,?JUMP,jump}]}.

jumping(state_timeout, jump,  Rabbit) ->
    io:format("~p~n",[jumping]),
    try find(Rabbit#rabbit.position) of
        Carrot ->
            %gen_server:call(Carrot,grab),
            {next_state, eating, Rabbit#rabbit{carrot = Carrot}, [{state_timeout,500,eat}]}
    catch
        _ ->
            NPos = sim_lib:next_pos(Rabbit#rabbit.position,Rabbit#rabbit.direction),
            case sim_lib:equal(Rabbit#rabbit.position, NPos) of
                true ->
                    NewDir = sim_lib:turn(Rabbit#rabbit.direction),
                    {next_state, jumping, 
                     Rabbit#rabbit{position = NPos, direction = NewDir}, 
                     [{state_timeout,500,jump}]};
                _ ->
                    {next_state, jumping,Rabbit#rabbit{position = NPos}, 
                     [{state_timeout,500,jump}]}
            end
    end;

jumping({call,Caller}, _Msg, Rabbit) ->
    {next_state, state_name, Rabbit, [{reply,Caller,ok}]}.

eating(state_timeout, eat, Rabbit) ->
    io:format("~p~n",[eating]),
        try gen_server:call(Rabbit#rabbit.carrot,bite) of
            _SomethingToEat ->
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
                end
        end.

splitting(state_timeout, split, Rabbit) ->
        io:format("~p~n",[splitting]),
    {next_state, splitting, Rabbit, [{state_timeout,?JUMP,split}]}.
state_name({call,Caller}, _Msg, Rabbit) ->
    {next_state, state_name, Rabbit, [{reply,Caller,ok}]}.

terminate(_Reason, _State, _Data) ->
    void.

code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

find(Position) ->
    Children = supervisor:which_children(carrots_sup),
    find(Position, [ Pid || {_,Pid,_,_} <- Children]).
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
            
