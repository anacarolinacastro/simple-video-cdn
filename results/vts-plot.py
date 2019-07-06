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
    miss = res['cacheZones']['cdn_cache']['responses']['miss']

    statys_2xx = res['serverZones']['_']['responses']['2xx']

    requests = res['connections']['requests']

    d = {'cache status': ['hit', 'expired', 'miss'],
        'count': [hit, expired, miss]}

    df = pd.DataFrame(d)
    f.write(str(port))
    f.write("\n")
    f.write(df.to_string())
    f.write("\n")
    f.write("--------------------------------------")
    f.write("\n")
    f.write("\n")

    print(df)

    p = (ggplot(df) +
    geom_bar(aes(x='cache status', y='count'), stat='identity') +
         ggtitle(algoritm + ' ('+str(port)+')')
    )

    ggsave(plot=p, filename=str(port), path="/files/"+algoritm)

f.close()
