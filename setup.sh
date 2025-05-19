green='\033[0;32m'
yellow='\033[0;33m'
nc='\033[0m'

echo -e "${green}Встановлення залежностей...${nc}"
sleep 2
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install iptables-persistent -y
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli libgbm1 pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

echo -e "${green}Перевірка Docker...${nc}"
if ! command -v docker &> /dev/null; then
  echo -e "${yellow}Docker не знайдено, встановлюємо...${nc}"
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  sudo usermod -aG docker $USER
  rm get-docker.sh
fi

if ! getent group docker > /dev/null; then
  sudo groupadd docker
fi

sudo usermod -aG docker $USER

echo -e "${green}Налаштування прав доступу до Docker...${nc}"
if [ -S /var/run/docker.sock ]; then
  sudo chmod 666 /var/run/docker.sock
else
  sudo systemctl start docker
  sudo chmod 666 /var/run/docker.sock
fi

# Якщо контейнер існує, зупинити і видалити його
if [ "$(docker ps -aq -f name=aztec-sequencer)" ]; then
  echo "Зупинка і видалення існуючого контейнера aztec-sequencer..."
  docker stop aztec-sequencer
  docker rm aztec-sequencer
fi

echo -e "${green}Налаштування iptables...${nc}"
if ! command -v iptables &> /dev/null; then
  sudo apt-get update -y
  sudo apt-get install -y iptables
fi

sudo iptables -I INPUT -p tcp --dport 40400 -j ACCEPT
sudo iptables -I INPUT -p udp --dport 40400 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
sudo sh -c "iptables-save > /etc/iptables/rules.v4"

echo -e "${green}Підготовка до запуску ноди...${nc}"
mkdir -p "$HOME/aztec-sequencer"
cd "$HOME/aztec-sequencer"

docker pull aztecprotocol/aztec:0.85.0-alpha-testnet.8

echo -e "${yellow}Введіть параметри для .evm:${nc}"
read -p "URL RPC Sepolia: " RPC
read -p "URL Beacon Sepolia: " CONSENSUS
read -p "Приватний ключ (0x…): " PRIVATE_KEY
read -p "Адреса гаманця (0x…): " WALLET

SERVER_IP=$(curl -s https://api.ipify.org)

cat > .evm <<EOF
ETHEREUM_HOSTS=$RPC
L1_CONSENSUS_HOST_URLS=$CONSENSUS
VALIDATOR_PRIVATE_KEY=$PRIVATE_KEY
P2P_IP=$SERVER_IP
WALLET=$WALLET
EOF

docker stop aztec-sequencer
docker rm aztec-sequencer
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
docker logs --tail 100 -f aztec-sequencer

echo -e "${green}Запуск контейнера з Aztec нодою...${nc}"
docker run -d \
  --name aztec-sequencer \
  --network host \
  --env-file "$HOME/aztec-sequencer/.evm" \
  -e DATA_DIRECTORY=/data \
  -e LOG_LEVEL=debug \
  -v "$HOME/my-node/node":/data \
  aztecprotocol/aztec:0.85.0-alpha-testnet.8 \
  sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer'

cd ~

echo -e "${green}Готово! Перевірка логів ноди...${nc}"
sleep 2
docker logs --tail 100 -f aztec-sequencer
