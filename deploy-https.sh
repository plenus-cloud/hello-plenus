#!/bin/sh

kubectl apply -f yaml-common/
kubectl apply -f yaml-https/

echo ""
echo "You can check pod status with command:"
echo "watch kubectl get po"
