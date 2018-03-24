-include("d.hrl").

-record(world, {carrots, rabbits, wolves, width, height}).

-record(carrot, {pid, pos, amount = ?FRESH, grabbed = false}).
-record(rabbit, {pid, pos, direction, belly = ?HUNGRY, carrot}).
-record(wolf, {pid, pos, direction, belly = ?HUNGRY, target}).

-record(pos, {x,y}).

