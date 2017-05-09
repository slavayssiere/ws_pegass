#!/bin/bash

version=$1

docker push slavayssiere/ws_pegass:$version

gcloud container  --project "formation-container-test" clusters get-credentials "cluster-formation-crf" --zone europe-west1-b
kubectl set image deployment/ws-pegass-deployment ws-pegass=slavayssiere/ws_pegass:$version --namespace=prd

curl http://104.155.35.213:31080/v1/version

