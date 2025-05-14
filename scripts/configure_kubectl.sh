#!/bin/bash

aws eks --region us-east-1 update-kubeconfig --name devopsshack-cluster
kubectl create ns webapps
kubectl apply -f ../manifests/sa.yml
kubectl apply -f ../manifests/role.yml
kubectl apply -f ../manifests/rolebind.yml
kubectl apply -f ../manifests/sec.yml -n webapps
kubectl describe secret mysecretname -n webapps