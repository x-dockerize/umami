#!/usr/bin/env bash
set -e

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"

# --------------------------------------------------
# Kontroller
# --------------------------------------------------
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "❌ $ENV_EXAMPLE bulunamadı."
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "✅ $ENV_EXAMPLE → $ENV_FILE kopyalandı"
else
  echo "ℹ️  $ENV_FILE mevcut, güncellenecek"
fi

# --------------------------------------------------
# Yardımcı Fonksiyonlar
# --------------------------------------------------
gen_secret() {
  openssl rand -hex 32
}

set_env() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

set_env_once() {
  local key="$1"
  local value="$2"

  local current
  current=$(grep "^${key}=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2-)

  if [ -z "$current" ]; then
    set_env "$key" "$value"
  fi
}

# --------------------------------------------------
# Kullanıcıdan Gerekli Bilgiler
# --------------------------------------------------
read -rp "UMAMI_SERVER_HOSTNAME (örn: umami.example.com): " UMAMI_SERVER_HOSTNAME

echo
echo "--- Veritabanı ---"
read -rp "DB host (boş bırakılırsa: postgres): " INPUT_DB_HOST
DB_HOST="${INPUT_DB_HOST:-postgres}"
read -rp "DB user (boş bırakılırsa: umami): " INPUT_DB_USER
DB_USER="${INPUT_DB_USER:-umami}"
read -rp "DB name (boş bırakılırsa: umami): " INPUT_DB_NAME
DB_NAME="${INPUT_DB_NAME:-umami}"
read -rsp "DB password: " DB_PASSWORD
echo

DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:5432/${DB_NAME}"

# --------------------------------------------------
# .env Güncelle
# --------------------------------------------------
set_env UMAMI_SERVER_HOSTNAME "$UMAMI_SERVER_HOSTNAME"
set_env DATABASE_URL           "$DATABASE_URL"

# Secret — mevcut değerin üzerine yazılmaz
set_env_once APP_SECRET "$(gen_secret)"

# --------------------------------------------------
# Sonuçları Göster
# --------------------------------------------------
echo
echo "==============================================="
echo "✅ Umami .env başarıyla hazırlandı!"
echo "-----------------------------------------------"
echo "🌐 Hostname : https://$UMAMI_SERVER_HOSTNAME"
echo "🗄️  DB       : $DATABASE_URL"
echo "-----------------------------------------------"
echo "💡 İlk giriş: admin / umami"
echo "   (Giriş yaptıktan sonra şifreyi değiştirin)"
echo "==============================================="
