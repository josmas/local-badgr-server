set -m

/entrypoint.sh couchbase-server &

sleep 15

curl -v -X POST http://127.0.0.1:8091/pools/default -d memoryQuota=300 -d indexMemoryQuota=300
curl -v http://127.0.0.1:8091/node/controller/setupServices -d services=kv%2Cn1ql%2Cindex
curl -v http://127.0.0.1:8091/settings/web -d port=8091 -d username=Administrator -d password=password
curl -v -u Administrator:password -X POST http://127.0.0.1:8091/sampleBuckets/install -d '["travel-sample"]'

echo "Type: $TYPE, Master: $COUCHBASE_MASTER"

if [ "$TYPE" = "worker" ]; then
  sleep 15
  set IP=`hostname -I`
  couchbase-cli server-add --cluster=$COUCHBASE_MASTER:8091 --user Administrator --password password --server-add=$IP
  # Hack with the cuts, use jq may be better.
  #KNOWN_NODES=`curl -X POST -u Administrator:password http://$COUCHBASE_MASTER:8091/controller/addNode \
  #  -d hostname=$IP -d user=Administrator -d password=password -d services=kv,n1ql,index | cut -d: -f2 | cut -d\" -f 2 | sed -e   's/@/%40/g'`

  if [ "$AUTO_REBALANCE" = "true" ]; then
    echo "Auto Rebalance: $AUTO_REBALANCE"
    sleep 10
    couchbase-cli rebalance -c $COUCHBASE_MASTER:8091 -u Administrator -p password --server-add=$IP
    #curl -v -X POST -u Administrator:password http://$COUCHBASE_MASTER:8091/controller/rebalance --data "knownNodes=$KNOWN_NODES&ejectedNodes="
  fi;
fi;

fg 1
