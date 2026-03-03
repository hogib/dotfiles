#!/usr/bin/env bash
# WaybarCava.sh — Optimized for smoothness and performance

set -euo pipefail

# Cava kontrolü
if ! command -v cava >/dev/null 2>&1; then
  echo "cava not found in PATH" >&2
  exit 1
fi

# Bar karakterleri (Boşluktan doluya)
# İstersen boşluk yerine silik bir karakter de koyabilirsin.
# Mevcut dizilim: 0=▁, 1=▂ ... 
bar=" ▂▃▄▅▆▇█" 
dict="s/;//g"
bar_length=${#bar}

# Sed dictionary oluşturma
for ((i = 0; i < bar_length; i++)); do
  dict+=";s/$i/${bar:$i:1}/g"
done

# Single-instance guard (Önceki instance'ı temizle)
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
pidfile="$RUNTIME_DIR/waybar-cava.pid"
if [[ -f "$pidfile" ]]; then
  oldpid="$(cat "$pidfile" || true)"
  if [[ -n "$oldpid" ]] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" 2>/dev/null || true
    sleep 0.1 || true
  fi
fi
printf '%d' $$ >"$pidfile"

# Temp config dosyası ve çıkışta temizlik
config_file="$(mktemp "$RUNTIME_DIR/waybar-cava.XXXXXX.conf")"
cleanup() { rm -f "$config_file" "$pidfile"; }
trap cleanup EXIT INT TERM

# --- OPTİMİZE EDİLMİŞ CONFIG ---
# Framerate 60'a çekildi.
# Smoothing (yumuşatma) ayarları eklendi.
#!/usr/bin/env bash
# WaybarCava.sh — Optimized for smoothness and performance

set -euo pipefail

# Cava kontrolü
if ! command -v cava >/dev/null 2>&1; then
  echo "cava not found in PATH" >&2
  exit 1
fi

# Bar karakterleri (Boşluktan doluya)
# İstersen boşluk yerine silik bir karakter de koyabilirsin.
# Mevcut dizilim: 0=▁, 1=▂ ... 
bar=" ▂▃▄▅▆▇█" 
dict="s/;//g"
bar_length=${#bar}

# Sed dictionary oluşturma
for ((i = 0; i < bar_length; i++)); do
  dict+=";s/$i/${bar:$i:1}/g"
done

# Single-instance guard (Önceki instance'ı temizle)
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
pidfile="$RUNTIME_DIR/waybar-cava.pid"
if [[ -f "$pidfile" ]]; then
  oldpid="$(cat "$pidfile" || true)"
  if [[ -n "$oldpid" ]] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" 2>/dev/null || true
    sleep 0.1 || true
  fi
fi
printf '%d' $$ >"$pidfile"

# Temp config dosyası ve çıkışta temizlik
config_file="$(mktemp "$RUNTIME_DIR/waybar-cava.XXXXXX.conf")"
cleanup() { rm -f "$config_file" "$pidfile"; }
trap cleanup EXIT INT TERM

# --- OPTİMİZE EDİLMİŞ CONFIG ---
# Framerate 60'a çekildi.
# Smoothing (yumuşatma) ayarları eklendi.
cat >"$config_file" <<EOF
[general]
framerate = 60
bars = 10
# Barların hassasiyeti (daha düşük = daha az tepki, yüksek = tavan yapar)
sensitivity = 100

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7

[smoothing]
# Bu ayarlar "smooth" hissini verir:
# integral: Barların hareketini ortalar (jitter'ı azaltır). 0 ile 100 arası.
integral = 95
# gravity: Barların aşağı düşüş hızı. Çok düşükse havada asılı kalır, çok yüksekse titrer.
gravity = 10
# monstercat: Daha yumuşak, dalga benzeri bir görünüm için (0 veya 1)
monstercat = 1
# noise_reduction: Arka plan cızırtısını filtreler (0.10 - 0.77 arası dene)
noise_reduction = 0.77
EOF

# Çalıştır ve pipe'la
# LC_ALL=C eklemek bazen sed işlemlerini milisaniye mertebesinde hızlandırır
exec cava -p "$config_file" | sed -u "$dict"
