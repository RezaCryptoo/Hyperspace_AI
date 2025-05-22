#!/bin/bash

# Header section
echo "    ____                      ______                 __            "
echo "   / __ \\___  ____  ____ _   / ____/______  ______  / /_____  ____ "
echo "  / /_/ / _ \\/_  / / __ \`/  / /   / ___/ / / / __ \\/ __/ __ \\/ __ \\"
echo " / _, _/  __/ / /_/ /_/ /  / /___/ /  / /_/ / /_/ / /_/ /_/ / /_/ /"
echo "_/ |_|\\___/ /___/\\__,_/   \\____/_/   \\__, / .___/\\__/\\____/\\____/ "
echo "                                     /____/_/                      "

# Display Twitter and Telegram links
echo "🔹 Follow us on Twitter: @Reza_Cryptoo"
echo "🔹 Join our Telegram Channel: https://t.me/Rezaa_Cryptoo"

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Check if previous installation exists and remove it
echo "🔹 Checking for previous installation..."
if [ -d "/root/.aios" ]; then
    echo "🔹 Found previous installation, removing..."
    rm -rf /root/.aios
    echo "🔹 Previous installation removed."
fi

if [ -f "/usr/local/bin/aios-cli" ]; then
    echo "🔹 Removing previous aiOS CLI binary..."
    rm /usr/local/bin/aios-cli
    echo "🔹 aiOS CLI binary removed."
fi

if [ -f "/etc/systemd/system/aios.service" ]; then
    echo "🔹 Removing previous systemd service..."
    sudo rm /etc/systemd/system/aios.service
    echo "🔹 Previous systemd service removed."
fi

# Additional cleanup for models and hyperspace directories
sudo rm -rf /root/.cache/hyperspace/models/
sudo rm -rf /opt/hyperspace

# Install required packages
echo "🔹 Installing required packages..."
apt update && apt upgrade -y
apt install -y git curl sudo bash

# Install aiOS CLI
echo "🔹 Downloading and installing aiOS CLI..."
curl -s https://download.hyper.space/api/install | bash
source ~/.bashrc

# Create systemd service
echo "🔹 Creating systemd service for aiOS..."
cat <<EOF | sudo tee /etc/systemd/system/aios.service > /dev/null
[Unit]
Description=aiOS CLI Service
After=network.target

[Service]
ExecStart=/root/.aios/aios-cli start
Restart=always
RestartSec=5
User=root
WorkingDirectory=/root
Environment=PATH=/usr/local/bin:/usr/bin:/bin:/root/.aios

[Install]
WantedBy=multi-user.target
EOF

# Copy and set permissions for aios-cli
echo "🔹 Copying and setting permissions for aios-cli..."
sudo cp /root/.aios/aios-cli /usr/local/bin/
sudo chmod +x /usr/local/bin/aios-cli

# Reload systemd daemon to pick up new service
echo "🔹 Reloading systemd daemon..."
sudo systemctl daemon-reload

# Start and enable the service
echo "🔹 Starting aiOS service..."
sudo systemctl start aios.service
sudo systemctl enable aios.service

# Check service status
echo "🔹 Checking service status:"
sudo systemctl status aios.service --no-pager

# Prompt user to choose a model
echo "🔹 Please choose a model to download:"
echo "1. Qwen 1.5-1.8B-Chat"
echo "2. Phi-2"
echo "3. Mistral-7B-Instruct"
read -p "Enter the number of the model you want to download (1, 2 or 3): " model_choice

# Download the selected model
if [ "$model_choice" -eq 1 ]; then
    echo "🔹 Downloading Qwen 1.5-1.8B-Chat model..."
    aios-cli models add hf:second-state/Qwen1.5-1.8B-Chat-GGUF:Qwen1.5-1.8B-Chat-Q4_K_M.gguf
elif [ "$model_choice" -eq 2 ]; then
    echo "🔹 Downloading Phi-2 model..."
    aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf
elif [ "$model_choice" -eq 3 ]; then
    echo "🔹 Downloading Mistral-7B-Instruct model..."
    aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf
else
    echo "Invalid choice, exiting."
    exit 1
fi

# Prompt user for private key
read -p "Enter your Private Key: " PRIVATE_KEY

# Import private key
echo "🔹 Importing private key..."
echo "$PRIVATE_KEY" > /root/my-key.base58
aios-cli hive import-keys /root/my-key.base58

# Login and connect to Hive
echo "🔹 Logging into Hive..."
aios-cli hive login
echo "🔹 Connecting to Hive..."
aios-cli hive connect
echo "🔹 Selecting Tier 3..."
aios-cli hive select-tier 3

# Create a script for auto-renewing Hive connection
echo "🔹 Creating auto-renew script..."
cat <<EOF > /root/aios-renew.sh
#!/bin/bash
echo "Running aiOS Hive renewal - \$(date)" >> /var/log/aios-renew.log
aios-cli hive login
aios-cli hive connect
aios-cli hive select-tier 3
echo "✅ aiOS Hive renewed successfully!" >> /var/log/aios-renew.log
EOF

# Give execute permission to the renewal script
chmod +x /root/aios-renew.sh

# Set up a cron job to run the script every 5 hours
echo "🔹 Setting up Cron Job for execution every 5 hours..."
(crontab -l 2>/dev/null; echo "0 */5 * * * /root/aios-renew.sh >> /var/log/aios-renew.log 2>&1") | crontab -

echo "✅ Installation and setup completed successfully!"
