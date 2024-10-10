#!/bin/bash
# This script automates the setup of OctoFarm

echo "Updating system and installing dependencies..."
apt update
apt upgrade -y

apt install -y git 
apt install -y curl 

curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

apt install -y nodejs 
apt install -y npm

curl -fsSL https://pgp.mongodb.com/server-6.0.asc | tee /usr/share/keyrings/mongodb-server-6.0.gpg > /dev/null
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
apt update

apt install -y mongodb-org

echo "Cloning OctoFarm repository..."
git clone https://github.com/ZombiesLoveMe/OctoFarm-test
cd OctoFarm-test

echo "Installing npm dependencies..."
npm install
npm run build

echo "Creating .env file..."
cat > .env <<EOL
NODE_ENV=production
MONGO=mongodb://127.0.0.1:27017/octofarm
OCTOFARM_PORT=4000
EOL

echo "Building client..."
npm run build-client

echo "Starting MongoDB service..."
systemctl start mongod
systemctl enable mongod

mv ~/OctoFarm-test/OctoFarm.service ~/etc/systemd/system/

systemctl daemon-reload
systemctl enable octofarm
systemctl start octofarm

echo "Setup complete. You can now login via <your server IP>:4000"
