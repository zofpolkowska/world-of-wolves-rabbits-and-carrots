-include("d.hrl").

-record(world, {carrots, rabbits, wolves, width, height}).

-record(carrot, {pid, position, amount = ?FRESH, grabbed = false}).
-record(rabbit, {pid, position, direction, belly = ?HUNGRY, carrot = null, no_food = 0}).
-record(wolf, {pid, position, direction, belly = ?HUNGRY, target, no_food = 0
              }).

-record(pos, {x,y}).

