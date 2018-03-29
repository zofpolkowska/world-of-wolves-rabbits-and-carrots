-module(carrots_sup).
-include("../include/m.hrl").
-behaviour(supervisor).

-export([start_link/1, plant/1]).

-export([init/1]).

start_link(Parameters) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Parameters]).

init([Parameters]) ->
%    {ok, {{simple_one_for_one, 3, 60},
%         [{carrot,
%           {carrot_srv, start_link, []},
%           temporary, 1000, worker, [carrot_srv]}
%         ]}}.
    {ok, {{one_for_one, Parameters, 1}, []}}. 

plant(Parameters) ->
    [supervisor:start_child(?MODULE,
                            single({carrot,E})) || E <- lists:seq(1,Parameters)].
single(E) ->
    {E,
     {carrot_srv, start_link, [sim_lib:gen_pos(random)]},
     temporary,
     brutal_kill,
     worker,
     [carrot_srv]}.

