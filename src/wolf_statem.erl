-module(wolf_statem).
-include("../include/m.hrl").
-behaviour(gen_statem).

-export([start_link/0]).
-export([callback_mode/0, init/1, terminate/3, code_change/4]).
-export([state_name/3]).

start_link() ->
    gen_statem:start_link(?MODULE, [], []).

callback_mode() -> state_functions.


init([]) ->
    Wolf = #wolf{ pid = self(),
                  position = sim_lib:gen_pos(random),
                  direction = sim_lib:gen_dir(random),
                  belly = ?HUNGRY},
    {ok, state_name, Wolf}.

state_name({call,Caller}, _Msg, Wolf) ->
    {next_state, state_name, Wolf, [{reply,Caller,ok}]}.

terminate(_Reason, _State, _Data) ->
    void.

code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
