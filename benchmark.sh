#!/bin/bash

for i in $(seq 1 5)
do
    docker run --net="host" --rm anafrombr/go-wrk -redir -T 5000 -c 10 -d 30  http://0.0.0.0:80/live/hls/signal-$i/index.m3u8 > results/benchmark/signal-$i.log &
done
