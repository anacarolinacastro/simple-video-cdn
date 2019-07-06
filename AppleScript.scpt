tell app "Terminal"
    do script "cd /Users/ana.castro/Documents/UERJ/simple-video-cdn && make benchmark-signal1 && exit"
    do script "cd /Users/ana.castro/Documents/UERJ/simple-video-cdn && make benchmark-signal2 && exit"
    do script "cd /Users/ana.castro/Documents/UERJ/simple-video-cdn && make benchmark-signal3 && exit"
    do script "cd /Users/ana.castro/Documents/UERJ/simple-video-cdn && make benchmark-signal4 && exit"
    do script "cd /Users/ana.castro/Documents/UERJ/simple-video-cdn && make benchmark-signal5 && exit"
end tell
