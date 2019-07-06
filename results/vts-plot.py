import pandas as pd
from plotnine import *
import urllib.request
import json
import os

def get_json(url):
    req = urllib.request.Request(url)
    opener = urllib.request.build_opener()
    f = opener.open(req)
    return json.loads(f.read())

ports_range = os.environ['CACHE_PORTS_RANGE'].split('-')

algoritm = os.environ['LB_ALGORITM'].capitalize()
f = open("/files/" + algoritm + ".txt", "w")

data = []
first_port = int(ports_range[0])
last_port = int(ports_range[1])

requests_total = 0

for i, port in enumerate(range(first_port, last_port + 1)):
    url = "http://0.0.0.0:"+str(port)+"/status"
    res = get_json(url)

    hit = res['cacheZones']['cdn_cache']['responses']['hit']
    expired = res['cacheZones']['cdn_cache']['responses']['expired']
    updating = res['cacheZones']['cdn_cache']['responses']['updating']
    miss = res['cacheZones']['cdn_cache']['responses']['miss']
    total = hit + expired + updating + miss
    requests_total += total

    data.append({"id": i+1, "Cache status": "hit", "count": hit})
    data.append({"id": i+1, "Cache status": "expire", "count": expired})
    data.append({"id": i+1, "Cache status": "updating", "count": updating})
    data.append({"id": i+1, "Cache status": "miss", "count": miss})

    f.write("[CACHE " + str(i+1) + "] (port " + str(port) +")\n")
    f.write("hit: " + str(hit) + "\n")
    f.write("expire: " + str(expired) + "\n")
    f.write("updating: " + str(updating) + "\n")
    f.write("miss: " + str(miss) + "\n")
    f.write("sum: " + str(total) + "\n\n")

f.write("total requests: " + str(requests_total) + "\n\n")

df = pd.DataFrame(data)

p = (ggplot(df, aes(x='Cache status', y='count')) +
    geom_bar(aes(fill = 'factor(id)'), stat='identity') +
    labs(fill="Cache") +
    ggtitle(algoritm)
    )

ggsave(plot=p, filename=algoritm, path="/files/")

f.close()
