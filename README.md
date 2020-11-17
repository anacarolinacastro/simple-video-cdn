# Simple Video CDN
A minimal CDN for load balance studies purposes.

![Architecture](/images/architecture.png)


#### Docker services

- *simple-video-cdn_origin_1:* ingest/packager/origin
- *simple-video-cdn_cache_N:* cache server N
- *simple-video-cdn_lb_1:* load balancer
- *simple-video-cdn_healthchecker_1:* go application that do the health check
- *simple-video-cdn_redis_1*: redis db that stores the health and load data


## Running

#### Delivery
Delivery HLS and Dash video (two cache instances):
```bash
make run
```


#### Ingest
- Ingest video from ffmpeg filter:
```bash
make ingest
```

Or ingest another video to http://0.0.0.0:8080/ingest/signal-1.

#### Consume
- Consume the HLS playlist:
```bash
curl -s http://0.0.0.0:80/live/hls/signal-1/index.m3u8
```
- Consume the Dash play list:
```bash
curl -s http://0.0.0.0:80/live/dash/signal-1/index.mpd
```

## Built With
- [ffmpeg](https://github.com/FFmpeg/FFmpeg) - audio/video handler
- [nginx](https://github.com/nginx/nginx) - HTTP server and reverse proxy
- [nginx-ts-module](https://github.com/arut/nginx-ts-module) - receives MPEG-TS and serves HLS and DASH over HTTP
- [nginx-module-vts](https://github.com/vozlt/nginx-module-vts) - fetch host traffic status
- [Golang](https://golang.org/) - compiled language
- [Lua](https://www.lua.org/) - script language
- [Redis](https://redis.io/) - in-memory database

## Authors
Ana Carolina Castro - Initial work - Globo.com

## Acknowledgments
This is not a resilient architecture.
