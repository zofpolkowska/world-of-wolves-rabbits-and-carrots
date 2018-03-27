-module(carrot_srv).
-include("../include/m.hrl").
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    Carrot = #carrot{ pid = self(),
                      pos = sim_lib:gen_pos(random)},
    {ok, Carrot}.

handle_call(position, _From, Carrot) ->
    Reply = Carrot#carrot.pos,
    {reply, Reply, Carrot};
handle_call(amount, _From, Carrot) ->
    Reply = Carrot#carrot.amount,
    {reply, Reply, Carrot};
handle_call(grab, _From, Carrot) ->
    Reply = Carrot#carrot.grabbed,
    {reply, Reply, Carrot#carrot{grabbed = true}};    
handle_call(bite, _From, Carrot) ->
    case Carrot#carrot.amount of
        ?BITE ->
                        {reply, {leftovers, 0}, 
             Carrot#carrot{pid = self(), 
                           pos = Carrot#carrot.pos,
                           amount = 0,
                           grabbed = true}};
        _ ->
            Amount = Carrot#carrot.amount - ?BITE,
            {reply, {leftovers,Amount}, 
             Carrot#carrot{pid = self(), 
                           pos = Carrot#carrot.pos,
                           amount = Amount,
                           grabbed = true}}
    end;

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

%%%===================================================================
%%% Internal functions
%%%===================================================================
