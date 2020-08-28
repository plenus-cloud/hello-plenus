#!/bin/sh

kubectl apply -f yaml/

echo ""
echo "You can check pod status with command:"
echo "watch kubectl get po"
