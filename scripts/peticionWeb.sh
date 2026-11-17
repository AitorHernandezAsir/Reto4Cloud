while true; do
  for ip in "13.221.91.226 (Manager)" "50.17.103.119 (Worker1)" "18.209.67.15 (Worker2)" "100.59.206.51 (Worker3)"; do
    # Extraemos solo la IP limpia
    real_ip=$(echo $ip | cut -d' ' -f1)
    label=$(echo $ip | cut -d' ' -f2-)

    # Hacemos el curl y capturamos el código HTTP y el tiempo
    status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 1 http://$real_ip)
    echo "[$(date '+%T')] Node: $label ($real_ip) -> HTTP Status: $status"
  done
  echo "----------------------------------------"
  sleep 2
done
