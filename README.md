# Umami – Docker + Traefik + PostgreSQL

**Umami**, gizlilik odaklı, açık kaynaklı bir web analitik platformudur. Google Analytics'e self-hosted bir alternatif sunar; çerez kullanmaz, GDPR uyumludur.

---

## Gereksinimler

- Docker Engine + Docker Compose v2
- Çalışır durumda Traefik (`traefik-network` external network)
- Paylaşımlı PostgreSQL sunucusu (`postgres-network` external network)

---

## Proje Yapısı

```
umami/
├── .env.example
├── docker-compose.production.yml
├── install.sh
└── README.md
```

---

## Kurulum

### 1. Veritabanı Oluşturma

PostgreSQL sunucusunda Umami için kullanıcı ve veritabanı oluştur:

```sql
CREATE USER umami WITH PASSWORD 'STRONG_PASSWORD';
CREATE DATABASE umami OWNER umami;
```

---

### 2. Ortam Değişkenlerini Hazırla

`install.sh` çalıştır — hostname ve DB bilgilerini sorar, `APP_SECRET` otomatik üretir:

```bash
bash install.sh
```

Ya da manuel:

```bash
cp .env.example .env
# .env dosyasını düzenle
```

`.env` içinde doldurulması gereken alanlar:

| Değişken | Açıklama |
|---|---|
| `UMAMI_SERVER_HOSTNAME` | Umami'ye erişilecek domain (örn: `umami.example.com`) |
| `DATABASE_URL` | `postgresql://umami:PASSWORD@postgres:5432/umami` |
| `APP_SECRET` | Token imzalama secret'ı — `openssl rand -hex 32` ile üret |

> ⚠️ `APP_SECRET` ilk çalıştırma sonrası değiştirilmemelidir; tüm oturumlar geçersiz olur.

---

### 3. Servisi Başlat

```bash
docker compose -f docker-compose.production.yml up -d
```

---

## Traefik Entegrasyonu

- **Erişim:** IP kısıtlamalı (`trusted@file` middleware)
- **Entrypoint:** `https` (443)
- **TLS:** Cloudflare DNS challenge
- **Port:** 3000 (container içinde)

---

## İlk Giriş

| Alan | Değer |
|---|---|
| Kullanıcı adı | `admin` |
| Şifre | `umami` |

> ⚠️ İlk girişten hemen sonra şifreyi değiştir.

---

## Güncelleme

```bash
docker compose -f docker-compose.production.yml pull
docker compose -f docker-compose.production.yml up -d
```

`UMAMI_VERSION` değerini `.env` içinde güncellemeyi unutma.

---

## Faydalı Linkler

- [Umami Docs](https://umami.is/docs)
- [GitHub](https://github.com/umami-software/umami)
- [Container Registry](https://github.com/umami-software/umami/pkgs/container/umami)
