
-module(fis_sup).

-behaviour(supervisor).

%% API functions
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
  Children = [
    ?CHILD(fis_event, worker),
    ?CHILD(fis_tcpflow, worker),
    webserver( fun fis_http:handle_http/1 )
  ],

  RestartStrategy = {one_for_one, 0, 1},

  {ok, {RestartStrategy, Children}}.

webserver(Handler) ->
  Port = 8000,
  MaxConnections = 1024,

  {webserver, {misultin, start_link, [[{port, Port},
                            {max_connections, MaxConnections},
                            {loop, Handler}]]},
   permanent, 2000, worker, [misultin]}.