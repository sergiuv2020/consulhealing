#!/usr/bin/env bash
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
  if [ "${CHECK_ID_ARRAY[$i]}" = "service:repsrv:backend-dev:9100" ]; then
    CHECKJOB=$(curl http://172.29.100.189:8080/job/TestPlatformDeployment/job/ReportingService/lastBuild/api/json | jq ".building")
    if [ "${CHECKJOB}" = "false" ]; then
      echo -e "Triggering Jenkins job Deploy DEV Reporting"
      curl -X POST "http://172.29.100.189:8080/job/TestPlatformDeployment/job/ReportingService/buildWithParameters?Checkout_and_Test=no&Build_and_Push_Image=no&Deploy_Dev=yes&Deploy_Prod=no"
    else
      echo -e "Jenkins job Deploy DEV Reporting is already running, Checking status in 10 seconds"
    fi
  fi
  if [ "${CHECK_ID_ARRAY[$i]}" = "service:repsrv:backend-prod:9000" ]; then
    CHECKJOB=$(curl http://172.29.100.189:8080/job/TestPlatformDeployment/job/ReportingService/lastBuild/api/json | jq ".building")
    if [ "${CHECKJOB}" = "false" ]; then
      echo -e "Triggering Jenkins job Deploy PROD Reporting"
      curl -X POST "http://172.29.100.189:8080/job/TestPlatformDeployment/job/ReportingService/buildWithParameters?Checkout_and_Test=no&Build_and_Push_Image=no&Deploy_Dev=no&Deploy_Prod=yes"
    else
      echo -e "Jenkins job Deploy PROD Reporting is already running, Checking status in 10 seconds"
    fi
  fi
  if [ "${CHECK_ID_ARRAY[$i]}" = "service:repsrv:frontend-dev:8080" ]; then
    CHECKJOB=$(curl http://172.29.100.189:8080/job/TestPlatformDeployment/job/TestDasboard/lastBuild/api/json | jq ".building")
    if [ "${CHECKJOB}" = "false" ]; then
      echo -e "Triggering Jenkins job Deploy DEV Dashboard"
      curl -X POST "http://172.29.100.189:8080/job/TestPlatformDeployment/job/TestDasboard/buildWithParameters?Checkout_and_Test=no&Build_and_Push_Image=no&Deploy_Dev=no&Deploy_Prod=yes"
    else
      echo -e "Jenkins job Deploy DEV Dashboard is already running, Checking status in 10 seconds"
    fi
  fi
  if [ "${CHECK_ID_ARRAY[$i]}" = "service:repsrv:frontend-prod:80" ]; then
    CHECKJOB=$(curl http://172.29.100.189:8080/job/TestPlatformDeployment/job/TestDasboard/lastBuild/api/json | jq ".building")
    if [ "${CHECKJOB}" = "false" ]; then
      echo -e "Triggering Jenkins job Deploy PROD Dashboard"
      curl -X POST "http://172.29.100.189:8080/job/TestPlatformDeployment/job/TestDasboard/buildWithParameters?Checkout_and_Test=no&Build_and_Push_Image=no&Deploy_Dev=no&Deploy_Prod=yes"
    else
      echo -e "Jenkins job Deploy PROD Dashboard is already running, Checking status in 10 seconds"
    fi
  fi
break
else
  echo -e "${NC}Status for ${CHECK_ID_ARRAY[$i]} is ${STATUS_ARRAY[$i]}"
fi
done
