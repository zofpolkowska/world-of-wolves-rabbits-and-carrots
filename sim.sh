#!/bin/sh

rebar3 compile
erl -pa _build/default/lib/sim/ebin
