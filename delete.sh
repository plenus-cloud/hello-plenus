#!/bin/sh

kubectl delete -f yaml/
kubectl create secret generic hello-css --from-file=css/ --dry-run=client -o yaml | kubectl delete -f -
kubectl create secret generic hello-images --from-file=images/ --dry-run=client -o yaml | kubectl delete -f -
