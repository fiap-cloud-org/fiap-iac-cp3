# Imita a imagem Ubuntu 22.04 das nuvens: curl, python3 e cron já instalados.
FROM ubuntu:22.04
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl python3 cron ca-certificates \
 && rm -rf /var/lib/apt/lists/*
