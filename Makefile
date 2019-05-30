build-origin:
	docker build -t nginx-rtmp .

run-origin: build-origin
	docker run -it -p 1935:1935 -p 8080:8080 --rm nginx-rtmp

run:
	docker-compose up --scale cache=2

ingest:
	docker run  --net="host" --rm -v $(shell pwd):/files jrottenberg/ffmpeg:4.1 -re -i /files/videos/bunny.mp4 -bsf:v h264_mp4toannexb -c copy -f mpegts http://127.0.0.1:8080/ingest/bbb
