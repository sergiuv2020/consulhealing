echo '#!/usr/bin/env bash
RED="\033[0;31m"
NC="\033[0;32m"
read -r JSON
echo "Consul watch request:"
STATUS_ARRAY=($(echo $JSON | jq -r ".[].Status"))
CHECK_ID_ARRAY=($(echo $JSON | jq -r ".[].CheckID"))
LENGTH=${#STATUS_ARRAY[@]}
for (( i=0; i<${LENGTH}; i++ ));
do
if [ "${STATUS_ARRAY[$i]}" != "passing" ]; then
  echo -e "${RED}Status for ${CHECK_ID_ARRAY[$i]} is ${STATUS_ARRAY[$i]}"
  if [ "${CHECK_ID_ARRAY[$i]}" = "service:reporting-service" ]; then
    echo -e "Triggering Jenkins job Deploy DEV Reporting"
    curl -X POST http://172.29.101.40:8080/job/Deploy%20DEV%20Reporting/build
  fi
  if [ "${CHECK_ID_ARRAY[$i]}" = "service:reporting" ]; then
    echo -e "Triggering Jenkins job Deploy PROD Reporting"
    curl -X POST http://172.29.101.40:8080/job/Deploy%20Prod%20Reporting/build
  fi
break
else
  echo -e "${NC}Status for ${CHECK_ID_ARRAY[$i]} is ${STATUS_ARRAY[$i]}"
fi
done
