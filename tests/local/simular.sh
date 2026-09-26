#!/usr/bin/env bash
# Simula as duas máquinas de uma nuvem com Docker e roda o script de
# inicialização de verdade (o mesmo que vai no user_data / custom_data):
#   web  -> rede com internet + rede interna (como a sub-rede pública)
#   priv -> só a rede interna, sem internet (como a sub-rede privada)
# Uso: ./simular.sh        sobe, testa e deixa a página em http://localhost:18380
#      ./simular.sh down   remove containers e rede
set -euo pipefail
cd "$(dirname "$0")"
ROOT=$(cd ../.. && pwd)
P=fiap-iac-cp3
PORT=${PORT:-18380}

down() {
  docker rm -f "$P-web" "$P-priv" >/dev/null 2>&1 || true
  docker network rm "$P-peering" >/dev/null 2>&1 || true
}
if [ "${1:-}" = "down" ]; then down; echo "removido"; exit 0; fi
down

tf() {
  docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp -v "$ROOT":/w -w /w/tests/local \
    hashicorp/terraform:1.9 "$@"
}
echo "1/4 renderizando o user data com o módulo web-page"
tf init -input=false >/dev/null
tf apply -auto-approve -input=false >/dev/null
mkdir -p .out
tf output -raw web > .out/web.sh
tf output -raw priv > .out/priv.sh

echo "2/4 subindo as duas máquinas"
docker build -q -t "$P-vm-sim" . >/dev/null
docker network create --internal --subnet 172.29.0.0/24 "$P-peering" >/dev/null
docker run -d --name "$P-priv" --network "$P-peering" --ip 172.29.0.20 \
  -v "$PWD/.out:/init:ro" "$P-vm-sim" sleep infinity >/dev/null
docker run -d --name "$P-web" -p "127.0.0.1:$PORT:80" \
  -v "$PWD/.out:/init:ro" "$P-vm-sim" sleep infinity >/dev/null
docker network connect --ip 172.29.0.10 "$P-peering" "$P-web"

echo "3/4 rodando o script de inicialização"
docker exec "$P-priv" bash /init/priv.sh 2>/dev/null | tail -1
docker exec "$P-web" bash /init/web.sh 2>/dev/null | tail -1

echo "4/4 testando"
docker exec "$P-web" cp3-peer-check
docker exec "$P-priv" cp3-peer-check
fail=0
check() { if eval "$2"; then echo "  ok    $1"; else echo "  FALHA $1"; fail=1; fi; }
check "página da web em http://localhost:$PORT" \
  "curl -fs http://localhost:$PORT/ | grep -q 'Esta página veio da'"
check "web alcança priv pelo IP privado" \
  "docker exec $P-web cat /var/www/html/peer.json | grep -q '\"ok\":true'"
check "priv alcança web pelo IP privado" \
  "docker exec $P-priv cat /var/www/html/peer.json | grep -q '\"ok\":true'"
check "priv sem internet (usou python3 no lugar do Apache)" \
  "! docker exec $P-priv curl -s -m 4 -o /dev/null http://example.com"
exit $fail
