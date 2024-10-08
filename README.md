# Easy peasy LNbits, Pheonixd, Caddy script

Tested on an Ubuntu 22.04 server on https://www.lunanode.com/ with their default user named `ubuntu`, but you could adapt the install.sh script for other enviroments. Before running you can edit the install.sh file to latest release of pheonixd, this script uses v0.3.4.

Set up your domains DNS records to your lunanode instance, by adding an "A" record to your lunanodes ip address.

![image](https://github.com/user-attachments/assets/67451a4e-46eb-46ff-896f-8b20739bbca6)

SSH into your lunanode instance `ssh ubuntu@<instance-ip>` and run:
```sh
wget https://raw.githubusercontent.com/lnbits/lnbits-pheonixd-script/main/install.sh &&
chmod +x install.sh &&
sudo ./install.sh
```
Useful commands:
```sh
# To start/stop pheonixd
sudo systemctl stop phoenixd.service
sudo systemctl start phoenixd.service

# To start/stop lnbits
sudo systemctl stop lnbits.service
sudo systemctl start lnbits.service

# For logs
journalctl -u lnbits.service --output cat -f
journalctl -u phoenixd.service --output cat -f

# To start/stop caddy
sudo stop caddy
sudo start caddy
```
For updating LNbits:
```sh
cd lnbits
git pull
poetry install
sudo systemctl stop lnbits.service
sudo systemctl start lnbits.service
```
