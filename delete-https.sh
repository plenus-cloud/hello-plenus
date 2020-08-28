#!/bin/sh

kubectl delete -f yaml-common/
kubectl delete -f yaml-https/
kubectl delete secret hello-plenus-tls
