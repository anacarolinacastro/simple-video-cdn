build:
	docker build -t nginx-rtmp .

run: build
	docker run -it -p 1935:1935 -p 8080:8080 --rm nginx-rtmp

ingest:
	ffmpeg -re -i videos/Big_Buck_Bunny_360_10s_1MB.mp4 -bsf:v h264_mp4toannexb -c copy -f mpegts http://127.0.0.1:8080/ingest/bbb
