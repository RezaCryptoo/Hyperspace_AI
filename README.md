
# Running HyperSpace CLI

To run **HyperSpace CLI** and connect to the network, follow these steps:


### 1️⃣ Create a Wallet and Save Your Private Key

First, you need to create a **wallet** and store your **private key**:

- Visit the **HyperSpace Node** website:  
  [https://node.hyper.space/](https://node.hyper.space/)
  
- Create a wallet on the website and receive your **private key**.  
- Make sure to store your **private key** in a safe place, as you will need it to connect to the network.

### 2️⃣ Download the Installation Script

To download and install **HyperSpace Node**, use the provided script. Follow these steps:

- Download the installation script using the following command:

  ```bash
  git clone https://github.com/RezaCryptoo/Hyperspace_AI.git
  cd Hyperspace_AI
  ```

### 3️⃣ Run the Installation Script
Execute the following command:
```bash
sudo bash -c 'chmod +x install-aios.sh && ./install-aios.sh'
```

### 4️⃣ Select a Model
After installation, you will be prompted to select a model to download. Enter the corresponding number:
- `1` for **Qwen 1.5-1.8B-Chat**
- `2` for **Phi-2**

Example:
```
Select a model to download:
1. Qwen 1.5-1.8B-Chat
2. Phi-2
Enter your choice: 1
```

### 5️⃣ Enter Your Private Key
After selecting the model, you will be asked to enter your private key for connection.

```
Enter your Private Key:
```
💡 **Make sure you enter the correct private key!**

---
✅ **Installation Completed Successfully!**

You can now check your wallet information and points using the following commands:

🔹 **Check Wallet Information:**
```bash
aios-cli hive whoami
```

🔹 **Check Points:**
```bash
aios-cli hive points
```

---

📢 **Follow for Updates:**
- Twitter: [https://x.com/Reza_Cryptoo](https://x.com/Reza_Cryptoo)
- Telegram: [https://t.me/Rezaa_Cryptoo](https://t.me/Rezaa_Cryptoo)

