-include("d.hrl").

-record(world, {carrots, rabbits, wolves, width, height}).

-record(carrot, {pid, position, amount = ?FRESH, grabbed = false}).
-record(rabbit, {pid, position, direction, belly = ?HUNGRY, carrot}).
-record(wolf, {pid, position, direction, belly = ?HUNGRY, target}).

-record(pos, {x,y}).
