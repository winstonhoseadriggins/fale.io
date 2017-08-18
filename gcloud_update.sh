#!/bin/bash
rm -rf public
git pull
git submodule init
git submodule update
hugo
gcloud config set account fabiolocati@gmail.com
gcloud config set project fales-infra
gsutil -m cp -r public/* gs://fale.io
gsutil -m acl ch -r -u AllUsers:R gs://fale.io
gsutil web set -m index.html -e 404 gs://fale.io
