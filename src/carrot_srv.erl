-module(carrot_srv).
-include("../include/m.hrl").
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start_link(Position) ->
    gen_server:start_link(?MODULE, [Position], []).

init([Position]) ->
    Carrot = #carrot{ pid = self(),
                      position = Position },
    {ok, Carrot}.

handle_call(bite, _From, Carrot) when Carrot#carrot.amount > 0 ->
    Left = Carrot#carrot.amount - ?BITE,
    {reply, Left, 
     Carrot#carrot{amount = Left}};

handle_call(bite, _From, Carrot) ->
    {stop, normal, 0, Carrot};

handle_call(amount, _From, Carrot) ->
    {reply, Carrot#carrot.amount, Carrot};

handle_call(position, _From, Carrot) ->
    {reply, Carrot#carrot.position, Carrot};

handle_call(terminate, _From, Carrot) ->
    {stop, normal,ok, Carrot}.

handle_cast(_Msg, Carrot) ->
    {noreply, Carrot}.


handle_info(_Info, Carrot) ->
    {noreply, Carrot}.


terminate(_Reason, _Carrot) ->
    ok.

code_change(_OldVsn, Carrot, _Extra) ->
{ok, Carrot}.
