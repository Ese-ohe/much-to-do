#!/bin/bash
kind load docker-image muchtodo-app:latest --name muchtodo-cluster
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/mongodb/
kubectl apply -f kubernetes/backend/
kubectl apply -f kubernetes/ingress.yaml
kubectl get pods -n muchtodo
kubectl get svc -n muchtodo
