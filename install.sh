#!/bin/bash

wget https://raw.githubusercontent.com/lnbits/lnbits/snapcraft/lnbits.sh && 
chmod +x lnbits.sh && 
./lnbits.sh

# Install pheonix 
# Change here to latest from https://github.com/ACINQ/phoenixd/releases

wget https://github.com/ACINQ/phoenixd/releases/download/v0.3.4/phoenix-0.3.4-linux-x64.zip &&
chmod +x phoenix-0.3.4-linux-x64/phoenixd &&
cat .pheonix/phoenix.conf
read -p "Copy the http-password and put somewhere safe then press enter"


# Make pheonixd service file

cat <<EOF > /etc/systemd/system/phoenixd.service
[Unit]
Description=phoenixd
After=network.target

[Service]
ExecStart=/home/ubuntu/phoenix-0.3.4-linux-x64/phoenixd
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF


# Make lnbits service file

cat <<EOF > /etc/systemd/system/lnbits.service
[Unit]
Description=LNbits
Wants=pheonix.service
After=pheonix.service

[Service]
WorkingDirectory=/home/ubuntu/lnbits
ExecStart=/home/ubuntu/lnbits.sh
User=ubuntu
Restart=always
TimeoutSec=120
RestartSec=30
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# Start services

sudo systemctl enable phoenixd.service
sudo systemctl start phoenixd.service

sudo systemctl enable lnbits.service
sudo systemctl start lnbits.service

# Install caddy

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

# Make Caddyfile

read -p "Enter the url you will be using and press enter: " USER_INPUT

# Export the input as a global environment variable
export MY_CADDY_URL="$USER_INPUT"

cat <<EOF > /home/ubuntu/Caddyfile
{env.MY_CADDY_URL} {
  handle /api/v1/payments/sse* {
    reverse_proxy 0.0.0.0:5000 {
      header_up X-Forwarded-Host {env.MY_CADDY_URL}
      transport http {
         keepalive off
         compression off
      }
    }
  }
  reverse_proxy 0.0.0.0:5000 {
    header_up X-Forwarded-Host {env.MY_CADDY_URL}
  }
}
EOF

sudo caddy stop
sudo caddy start

read -p "Congrats, navigate to your url and as long as your dns is set up and propgated it will work."
