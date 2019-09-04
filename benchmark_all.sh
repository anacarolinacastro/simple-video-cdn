algoritms=("random" "round_robin" "least_conn" "consistent_hash" "consistent_hash_bound_load")
# algoritms=("consistent_hash" "consistent_hash_bound_load")
# algoritms=("consistent_hash_bound_load")
# algoritms=("consistent_hash")
for i in "${algoritms[@]}"
do
    echo $i
    LB_ALGORITM=$i make run &
    sleep 40;
    LB_ALGORITM=$i SIGNALS=10 make benchmark;
    sleep 30;
    LB_ALGORITM=$i make plot;
    make down;
    sleep 20
done
