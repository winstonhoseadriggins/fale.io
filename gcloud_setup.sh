#!/bin/bash
gcloud config set account fabiolocati@gmail.com
gcloud config set project fales-infra
gsutil -m mb gs://fale.io
gcloud compute backend-buckets create fale-io-bucket --gcs-bucket-name fale.io --enable-cdn

gcloud compute url-maps create fale-io --default-service static-bucket

gcloud compute url-maps add-path-matcher web-map --default-service web-map-backend-service --path-matcher-name bucket-matcher --backend-bucket-path-rules=/*=static-bucket
gcloud compute forwarding-rules listi

# gcloud compute url-maps invalidate-cdn-cache [URL_MAP_NAME]  --path "/images/foo.jpg"
