# encoding: utf-8

from datetime import datetime
from subprocess import call

SIGNALS = 10
ALGORITHMS = ["round_robin", "least_conn", "random", "consistent_hash", "consistent_hash_bound_load"]

def make_table(type, caption):
    t = open("./benchmark-"+type+"-table.txt", "w")

    t.write("% ---- " + datetime.now().strftime("%d/%m/%Y %H:%M:%S") + " ----\n")
    t.write("\\begin{center}\n")
    t.write("\\begin{center}\n")
    t.write("\\captionsetup{justification=centering}\n")
    t.write("\\captionof{table}"+ caption+"\n")
    t.write("\\begin{tabular}{ccccccccccc}\n")
    t.write("\\textbf{Signal} &\\textbf{Random} &\\textbf{Round Robin} &\\textbf{Least Conn} &\\textbf{CH} &\\textbf{CHBL}\n")
    t.write("\\\\\n")
    t.write("\\hline\n")

    all_data = list()
    count = [0] * 5

    for i in range(SIGNALS):
        data = list()
        signal = str(i + 1)
        for k in range(len(ALGORITHMS)):
            algoritm = ALGORITHMS[k]
            file = open("results/benchmark/signal-"+algoritm+"-"+signal+".log")
            res = file.readlines()
            if type == "err":
                data.append(
                    int(res[-1].replace("Number of Errors:\t", "").replace("\n", "")))

            elif type == "avg":
                avg = res[-4].replace("Avg Req Time:\t\t", "").replace("ms\n", "")
                if avg.endswith("s\n"):
                    avg = avg.replace("s\n", "")
                    avg = float(avg)
                else:
                    avg = float(avg)
                    avg = avg/1000
                data.append(float(format(avg, '.4f')))

            count[k] += data[k]
        all_data.append(data)

        t.write("signal-"+signal+" & " + str(all_data[i][0]) + " & " + str(all_data[i][1]) + " & " + str(all_data[i][2]) + " & " + str(all_data[i][3]) + " & " + str(all_data[i][4]) + "\\\\\n")

    t.write("\\hline\n")
    if type == "err":
        t.write("\\textit{Total} & \\textit{" + str(count[0]) + "} & \\textit{" + str(count[1]) + "} & \\textit{" + str(
            count[2]) + "} & \\textit{" + str(count[3]) + "} & \\textit{" + str(count[4]) + "}\\\\\n")
    elif type == "avg":
        t.write("\\textit{Media} &\\textit{" + str(count[0]/SIGNALS) + "} &\\textit{" + str(count[1]/SIGNALS) + "} &\\textit{" + str(
            count[2]/SIGNALS) + "} &\\textit{" + str(count[3]/SIGNALS) + "} &\\textit{" + str(count[4]/SIGNALS) + "}\\\\\n")

    t.write("\\end{tabular}\n")
    t.write("\\end{center}\n")
    t.write("\\vspace{3mm}\n")
    t.write("Fonte: A autora, \\UERJano.\n")
    t.write("\\end{center}\n")
    t.write("\\vspace{3mm}\n")
    t.close()


make_table("avg", "{Tempo médio(em segundos) de resposta por sinal para os algoritmos estudados.}\\label{tab: avg_req}")
make_table("err", "{Números de erros por sinal para os algoritmos estudados.}\\label{tab: err_req}")
