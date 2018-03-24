-module(rabbit_statem).
-include("../include/m.hrl").

-behaviour(gen_statem).

-export([start_link/0]).
-export([callback_mode/0, init/1, terminate/3, code_change/4]).
-export([state_name/3,jumping/3, eating/3]).

-export([find/1]).
start_link() ->
    gen_statem:start_link(?MODULE, [], []).

callback_mode() -> state_functions.


init([]) ->
    Rabbit = #rabbit{ pid = self(),
                      pos = sim_lib:gen_pos(random),
                      direction = sim_lib:gen_dir(random),
                      belly = ?HUNGRY },
    {ok, jumping, Rabbit, [{state_timeout,?JUMP,jump}]}.

jumping(state_timeout, jump,  Rabbit) ->
   % io:format("~p~n",[jumping]),
    try find(Rabbit#rabbit.pos) of
        Carrot ->
            gen_server:call(Carrot,grab),
            {next_state, eating, Rabbit#rabbit{carrot = Carrot}, [{state_timeout,500,eat}]}
    catch
        _ ->
            NPos = sim_lib:next_pos(Rabbit#rabbit.pos,Rabbit#rabbit.direction),
            {next_state, jumping, Rabbit#rabbit{pos = NPos}, [{state_timeout,500,jump}]}
    end;

jumping({call,Caller}, _Msg, Rabbit) ->
    {next_state, state_name, Rabbit, [{reply,Caller,ok}]}.

eating(state_timeout, eat, Rabbit) ->
        try gen_server:call(Rabbit#rabbit.carrot,bite) of
        {leftovers,_Amount} ->
            {next_state, eating, Rabbit,[{state_timeout,500,eat}]}; 
           finished ->
                Belly = Rabbit#rabbit.belly,
            {next_state, jumping, Rabbit#rabbit{belly = Belly + 1, carrot = no}, 
             [{state_timeout,?JUMP,jump}]}  
        catch
            _ ->
                 {next_state, jumping, Rabbit, [{state_timeout,?JUMP,jump}]}  

        end.
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
    find(Position, carrots_sup:children()).
find(_, []) ->
    throw(failure);
find(Position,[Head|Rest]) ->
    case sim_lib:equal(gen_server:call(Head, position),Position) of
        true ->
            Head;
        _ ->
            find(Position, Rest)
    end.
            