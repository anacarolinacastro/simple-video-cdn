import pandas as pd
from plotnine import *
import urllib.request
import json


def get_json(url):
    req = urllib.request.Request(url)
    opener = urllib.request.build_opener()
    f = opener.open(req)
    return json.loads(f.read())


# shoul get those as env var
ports = [8090, 8091, 8092, 8093, 8094]
algoritm = "round-robin"
f = open("/files/"+algoritm+"/results.txt", "w")

for i, port in enumerate(ports):
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
