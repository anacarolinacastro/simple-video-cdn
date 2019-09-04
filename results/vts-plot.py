import pandas as pd
from plotnine import *
import urllib.request
import json
import os
from datetime import datetime

def get_json(url):
    req = urllib.request.Request(url)
    opener = urllib.request.build_opener()
    f = opener.open(req)
    return json.loads(f.read())

ports_range = os.environ['CACHE_PORTS_RANGE'].split('-')

algoritm = os.environ['LB_ALGORITM']
title_algoritm = os.environ['LB_ALGORITM'].capitalize().replace("_", " ")

f = open("/files/" + algoritm + ".txt", "w")
f.write("---- " + datetime.now().strftime("%d/%m/%Y %H:%M:%S") + " ----\n")
f.write("---- " + title_algoritm + " ----\n")

t = open("/files/" + algoritm + "-table.txt", "w")
t.write("\\begin{center}\n")
t.write("\\begin{center}\n")
t.write("\\captionsetup{justification=centering}\n")
t.write("\\captionof{table}{Estatisticas de cache para o algoritmo \\textit{" + title_algoritm + "}.}\label{tab:"+title_algoritm+"}\n")
t.write("\\begin{tabular}{ ccccccccccc }\n")
t.write("\\textbf{Cache}&\\textbf{Port}&\\textbf{Hit}&\\textbf{Expire}&\\textbf{Updating}&\\textbf{Miss}\n")
t.write("\\\\\n")
t.write("\hline\n")

data = []
first_port = int(ports_range[0])
last_port = int(ports_range[1])

total_hit = 0
total_expired = 0
total_updating = 0
total_miss = 0

requests_total = 0

for i, port in enumerate(range(first_port, last_port + 1)):
    url = "http://0.0.0.0:"+str(port)+"/status"
    res = get_json(url)

    has_cache = res.get('cacheZones', False)
    if has_cache:
        hit = res['cacheZones']['cdn_cache']['responses']['hit']
        expired = res['cacheZones']['cdn_cache']['responses']['expired']
        updating = res['cacheZones']['cdn_cache']['responses']['updating']
        miss = res['cacheZones']['cdn_cache']['responses']['miss']
    else:
        hit = 0
        expired = 0
        updating = 0
        miss = 0

    total = hit + expired + updating + miss
    total_hit += hit
    total_expired += expired
    total_updating += updating
    total_miss += miss
    requests_total += total

    cache_id = i + 1

    data.append({"id": cache_id, "Cache status": "hit", "count": hit})
    data.append({"id": cache_id, "Cache status": "expire", "count": expired})
    data.append({"id": cache_id, "Cache status": "updating", "count": updating})
    data.append({"id": cache_id, "Cache status": "miss", "count": miss})

    t.write(str(cache_id) + "&" + str(port) + "&" + str(hit) + "&" +
            str(expired) + "&" + str(updating) + "&" + str(miss) + "\\\\\n")

    f.write("[CACHE " + str(i+1) + "] (port " + str(port) +")\n")
    f.write("hit: " + str(hit) + "\n")
    f.write("expire: " + str(expired) + "\n")
    f.write("updating: " + str(updating) + "\n")
    f.write("miss: " + str(miss) + "\n")
    f.write("sum: " + str(total) + "\n\n")


    df = pd.DataFrame(data)

f.write("total requests: " + str(requests_total) + "\n\n")
f.close()

t.write("\\hline\n")
t.write("all&-&" + str(total_hit) + "&" + str(total_expired) + "&" + str(total_updating) + "&" + str(total_miss) + "\\\\\n")
t.write("\\end{tabular}\n")
t.write("\\end{center}\n")
t.write("\\vspace{3mm}\n")
t.write("Fonte: A autora, \\UERJano.\n")
t.write("\\end{center}\n")
t.write("\\vspace{3mm}\n")
t.close()

# p = (ggplot(df, aes(x='Cache status', y='count')) +
#     geom_bar(aes(fill = 'factor(id)'), stat='identity') +
#     labs(fill="Cache") +
#      ggtitle(title_algoritm)
#     )

# ggsave(plot=p, filename=algoritm, path="/files/")
