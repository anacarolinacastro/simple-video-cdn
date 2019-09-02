#!/bin/bash
for i in $(seq 1 $2)
do
    count=100
    if [ $i -eq "10" ]
    then
        count=500
    fi

    docker run --net="host" --rm anafrombr/go-wrk -redir -T 5000 -c $count -d 5  http://0.0.0.0:80/live/hls/signal-$i/index.m3u8 > results/benchmark/signal-$1-$i.log &
done
