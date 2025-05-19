#!/bin/bash

green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'

echo -e "${blue}Робимо оновлення  Aztec...${nc}"

docker pull aztecprotocol/aztec:0.85.0-alpha-testnet.8

docker stop aztec-sequencer
docker rm aztec-sequencer

rm -rf "$HOME/my-node/node/"*

docker run -d \
  --name aztec-sequencer \
  --network host \
  --env-file "$HOME/aztec-sequencer/.evm" \
  -e DATA_DIRECTORY=/data \
  -e LOG_LEVEL=debug \
  -v "$HOME/my-node/node":/data \
  aztecprotocol/aztec:0.85.0-alpha-testnet.8 \
  sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js \
    start --network alpha-testnet --node --archiver --sequencer'


sleep 1

docker logs --tail 100 -f aztec-sequencer
