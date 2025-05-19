green='\033[0;32m'
yellow='\033[0;33m'
red='\033[0;33m'
nc='\033[0m'

# створюємо тимчасовий файл
tmpf=$(mktemp) && \
# записуємо туди потрібний код
cat > "$tmpf" <<'EOF'
# 1) Отримуємо висоту останнього перевіреного блоку
TIP_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
  http://localhost:8080)

BLOCK_NUMBER=$(printf '%s' "$TIP_RESPONSE" | jq -r '.result.proven.number')

# Перевіряємо, що це ціле невід’ємне число
if ! [[ "$BLOCK_NUMBER" =~ ^[0-9]+$ ]]; then
  echo -e "${RED}Помилка: очікувалося ціле число, отримали: $BLOCK_NUMBER${NC}" >&2
  exit 1
fi

echo -e "${GREEN}Успішно отримали висоту блоку: $BLOCK_NUMBER${NC}"

sleep 2

# 2) Запитуємо proof — передаємо числа без лапок!
ARCHIVE_PROOF=$(curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"node_getArchiveSiblingPath\",\"params\":[$BLOCK_NUMBER,$BLOCK_NUMBER],\"id\":67}" \
  http://localhost:8080 | jq -r '.result')

# Перевіряємо, що proof не порожній
if [[ -z "$ARCHIVE_PROOF" || "$ARCHIVE_PROOF" == "null" ]]; then
  echo -e "${RED}Помилка: не вдалося отримати proof для блоку $BLOCK_NUMBER${NC}" >&2
  exit 1
fi

echo -e "${GREEN}Proof для блоку $BLOCK_NUMBER:${NC}"
echo "$ARCHIVE_PROOF"
EOF
# виконуємо цей тимчасовий скрипт
bash "$tmpf" && \
# видаляємо тимчасовий файл
rm -f "$tmpf"
;;
