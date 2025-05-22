#!/bin/bash

# Header section
echo "    ____                      ______                 __            "
echo "   / __ \\___  ____  ____ _   / ____/______  ______  / /_____  ____ "
echo "  / /_/ / _ \\/_  / / __ \`/  / /   / ___/ / / / __ \\/ __/ __ \\/ __ \\"
echo " / _, _/  __/ / /_/ /_/ /  / /___/ /  / /_/ / /_/ / /_/ /_/ / /_/ /"
echo "_/ |_|\\___/ /___/\\__,_/   \\____/_/   \\__, / .___/\\__/\\____/\\____/ "
echo "                                     /____/_/                      "

echo "🔹 Follow us on Twitter: @Reza_Cryptoo"
echo "🔹 Join our Telegram Channel: https://t.me/Rezaa_Cryptoo"

# Check for root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Cleanup old installations
echo "🔹 Checking for previous installation..."
rm -rf /root/.aios /opt/hyperspace /root/.cache/hyperspace/models/
rm -f /usr/local/bin/aios-cli /etc/systemd/system/aios.service

# Install required packages
echo "🔹 Installing required packages..."
apt update && apt upgrade -y
apt install -y git curl sudo bash

# Install aiOS CLI
echo "🔹 Installing aiOS CLI..."
curl -s https://download.hyper.space/api/install | bash
source ~/.bashrc

# Create systemd service
echo "🔹 Creating aiOS service..."
cat <<EOF | tee /etc/systemd/system/aios.service > /dev/null
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

# Set permissions
cp /root/.aios/aios-cli /usr/local/bin/
chmod +x /usr/local/bin/aios-cli

# Start service
systemctl daemon-reload
systemctl start aios.service
systemctl enable aios.service

# Terminal menu for model selection (only models 1, 2, 3)
while true; do
  echo "Select a model to download:"
  echo "1) Qwen 1.5-1.8B-Chat"
  echo "2) Phi-2"
  echo "3) Mistral v0.1 Q4_K_S (TheBloke)"
  read -rp "Enter the number of your choice: " model_choice

  case $model_choice in
    1)
      echo "🔹 Downloading Qwen..."
      aios-cli models add hf:Qwen/Qwen1.5-1.8B-Chat-GGUF:qwen1_5-1_8b-chat-q4_k_m.gguf && break
      ;;
    2)
      echo "🔹 Downloading Phi-2..."
      aios-cli models add hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf && break
      ;;
    3)
      echo "🔹 Downloading Mistral v0.1..."
      aios-cli models add hf:TheBloke/Mistral-7B-Instruct-v0.1-GGUF:mistral-7b-instruct-v0.1.Q4_K_S.gguf && break
      ;;
    *)
      echo "❌ Invalid selection. Please try again."
      ;;
  esac
done

# Private key input in terminal
read -rsp "Enter your Private Key : " PRIVATE_KEY
echo
echo "$PRIVATE_KEY" > /root/my-key.base58
aios-cli hive import-keys /root/my-key.base58

# Connect to Hive
aios-cli hive login
aios-cli hive connect
aios-cli hive select-tier 3

# Create auto-renew script
cat <<EOF > /root/aios-renew.sh
#!/bin/bash
echo "Running aiOS Hive renewal - \$(date)" >> /var/log/aios-renew.log
aios-cli hive login
aios-cli hive connect
aios-cli hive select-tier 3
echo "✅ aiOS Hive renewed successfully!" >> /var/log/aios-renew.log
EOF

chmod +x /root/aios-renew.sh

# Set cron job
(crontab -l 2>/dev/null; echo "0 */5 * * * /root/aios-renew.sh >> /var/log/aios-renew.log 2>&1") | crontab -

echo "✅ Installation and setup completed!"
