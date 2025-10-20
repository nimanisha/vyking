#!/usr/bin/env bash
set -euo pipefail
CLUSTER_NAME=gitops-demo
REG_NAME=registry.localhost
REG_PORT=5000

if ! command -v k3d >/dev/null 2>&1; then
  echo "k3d is required. Install from https://k3d.io"
  exit 1
fi

if ! k3d registry list | grep -q ${REG_NAME}; then
  k3d registry create ${REG_NAME} --port ${REG_PORT}
fi

k3d cluster create ${CLUSTER_NAME} \
  --servers 1 \
  --agents 2 \
  --k3s-server-arg '--no-deploy=traefik' \
  --registry-use ${REG_NAME}:${REG_PORT}

kubectl config use-context k3d-${CLUSTER_NAME}
echo "Cluster created. Nodes:"
kubectl get nodes -o wide
echo "Local registry available at ${REG_NAME}:${REG_PORT}"
