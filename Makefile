.PHONY: benchmark

CACHE_PORTS_RANGE ?= 8090-8091
CACHE_POOL_SIZE ?= 2
LB_ALGORITM ?= round_robin
SIGNALS ?= 5

available-algoritms:
	@echo random round_robin least_conn consistent_hash

build-origin:
	docker build -t nginx-rtmp .

run-origin: build-origin
	docker run -it -p 1935:1935 -p 8080:8080 --rm nginx-rtmp

build:
	LB_ALGORITM=$(LB_ALGORITM) CACHE_PORTS_RANGE=$(CACHE_PORTS_RANGE) docker-compose build

run: build
	LB_ALGORITM=$(LB_ALGORITM) CACHE_PORTS_RANGE=$(CACHE_PORTS_RANGE) docker-compose up --scale cache=$(CACHE_POOL_SIZE)

down:
	LB_ALGORITM=$(LB_ALGORITM) CACHE_PORTS_RANGE=$(CACHE_PORTS_RANGE) docker-compose down

ingest:
	docker run --net="host" --rm -v $(shell pwd):/files jrottenberg/ffmpeg:4.1 -hide_banner \
        -re -f lavfi -i "testsrc2=size=1280x720:rate=30" -pix_fmt yuv420p \
        -c:v libx264 -x264opts keyint=30:min-keyint=30:scenecut=-1 \
        -tune zerolatency -profile:v high -preset veryfast -bf 0 -refs 3 \
        -b:v 1400k -bufsize 1400k \
        -vf "drawtext=fontfile='/files/fonts/OpenSans-Bold.ttf':text='%{localtime}:box=1:fontcolor=black:boxcolor=white:fontsize=100':x=40:y=400'" \
	-utc_timing_url "https://time.akamai.com/?iso" -use_timeline 0 -media_seg_name 'chunk-stream-$RepresentationID$-$Number%05d$.m4s' \
        -init_seg_name 'init-stream1-$RepresentationID$.m4s' \
        -window_size 5  -extra_window_size 10 -remove_at_exit 1 -adaptation_sets "id=0,streams=v id=1,streams=a" -f mpegts http://127.0.0.1:8080/ingest/signal-1

benchmark:
	./benchmark.sh $(LB_ALGORITM) $(SIGNALS)

build-plot:
	docker build results -t vts-plot

plot:build-plot
	docker run  --env LB_ALGORITM=$(LB_ALGORITM) --env CACHE_PORTS_RANGE=$(CACHE_PORTS_RANGE) -it -v $(PWD)/results:/files --network host --rm vts-plot
