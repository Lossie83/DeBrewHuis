#!/usr/bin/env bash
set -e

echo "🍺 DeBrewHuis Installer Starting..."

# ---- OS check ----
if ! grep -qi raspbian /etc/os-release; then
  echo "❌ This installer is intended for Raspberry Pi OS only"
  exit 1
fi

# ---- System update ----
sudo apt update
sudo apt install -y \
  git curl bluetooth bluez \
  python3 python3-pip python3-smbus \
  i2c-tools rclone

# ---- Enable interfaces ----
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_onewire 0

# ---- Node-RED install (official) ----
if ! command -v node-red >/dev/null; then
  echo "📦 Installing Node-RED..."
  bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
fi

# ---- Node-RED nodes ----
echo "📦 Installing Node-RED nodes..."
mkdir -p ~/.node-red
cd ~/.node-red
npm install \
  node-red-dashboard \
  node-red-contrib-telegrambot \
  node-red-contrib-pdfmake

# ---- Clone DeBrewHuis repo ----
cd ~
if [ ! -d "DeBrewHuis" ]; then
  git clone https://github.com/<your-username>/DeBrewHuis.git
fi

# ---- Deploy files ----
mkdir -p ~/brewlogs
cp DeBrewHuis/node-red/flows.json ~/.node-red/
cp DeBrewHuis/scripts/*.sh ~/
cp DeBrewHuis/tilt_ble.py ~/
chmod +x ~/tilt_ble.py ~/backup_brew.sh ~/restore_brew.sh

# ---- BLE permissions (Bookworm) ----
pip3 install bluepy
sudo setcap 'cap_net_raw,cap_net_admin+eip' "$(which python3)"

# ---- Enable Node-RED ----
sudo systemctl enable nodered.service
node-red-restart

echo "✅ DeBrewHuis installation complete"
echo "➡ Please reboot before commissioning"
