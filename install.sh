#!/bin/bash

# Install LNbits
echo "Downloading LNbits script..."
wget https://raw.githubusercontent.com/lnbits/lnbits/snapcraft/lnbits.sh
chmod +x lnbits.sh

# Install phoenix
echo "Downloading Phoenix..."
wget https://github.com/ACINQ/phoenixd/releases/download/v0.3.4/phoenix-0.3.4-linux-x64.zip
sudo apt install -y unzip
unzip phoenix-0.3.4-linux-x64.zip
chmod +x phoenix-0.3.4-linux-x64/phoenixd

# Make phoenixd service file
echo "Creating phoenixd service file..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/phoenixd.service
[Unit]
Description=phoenixd
After=network.target

[Service]
ExecStart=/home/ubuntu/phoenix-0.3.4-linux-x64/phoenixd
Restart=always
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF'

# Make lnbits service file
echo "Creating lnbits service file..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/lnbits.service
[Unit]
Description=LNbits
After=phoenixd.service

[Service]
WorkingDirectory=/home/ubuntu/lnbits
ExecStart=/home/ubuntu/lnbits.sh
User=ubuntu
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

# Start services
echo "Enabling and starting phoenixd service..."
sudo systemctl enable phoenixd.service
sudo systemctl start phoenixd.service

cd
sleep 10
cd .phoenix

# Display seed.dat contents
echo
echo
cat seed.dat
echo
read -p "IMPORTANT: Copy the phoenixd nodes seed and put somewhere safe then press enter"

# Display phoenix.conf contents
echo
echo
cat phoenix.conf
echo
read -p "IMPORTANT: Copy the http-password and put it somewhere safe then press enter"

cd

# Start lnbits service
echo "Enabling and starting lnbits service..."
sudo systemctl enable lnbits.service
sudo systemctl start lnbits.service

# Install caddy
echo "Installing caddy..."
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy

# Make Caddyfile
read -p "Enter the URL you will be using and press enter: " USER_INPUT

# Export the input as a global environment variable
export MY_CADDY_URL="$USER_INPUT"

echo "Creating Caddyfile..."
sudo bash -c "cat <<EOF > /home/ubuntu/Caddyfile
$MY_CADDY_URL {
  handle /api/v1/payments/sse* {
    reverse_proxy 0.0.0.0:5000 {
      header_up X-Forwarded-Host $MY_CADDY_URL
      transport http {
         keepalive off
         compression off
      }
    }
  }
  reverse_proxy 0.0.0.0:5000 {
    header_up X-Forwarded-Host $MY_CADDY_URL
  }
}
EOF"

echo "Restarting caddy..."
sudo caddy stop
sudo caddy start

read -p "Congrats, navigate to your URL and as long as your DNS is set up and propagated, it will work."
