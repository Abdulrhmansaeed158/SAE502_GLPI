#!/usr/bin/env bash
# Amorçage : crée le réseau Docker et CT-manager. Le reste est fait par Ansible.
set -euo pipefail
cd "$(dirname "$0")"

NET=infra_GLPI
SUBNET=192.168.70.0/24
GATEWAY=192.168.70.254
MANAGER_IP=192.168.70.1

docker network inspect "$NET" >/dev/null 2>&1 || \
  docker network create --subnet "$SUBNET" --gateway "$GATEWAY" "$NET"

docker build -t glpi-manager -f docker/Dockerfile.manager docker
docker rm -f ct-manager >/dev/null 2>&1 || true
docker run -d --name ct-manager --hostname ct-manager \
  --network "$NET" --ip "$MANAGER_IP" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":/work -v manager_ssh:/root/.ssh -w /work \
  glpi-manager
echo "CT-manager prêt : docker exec -it ct-manager bash"
