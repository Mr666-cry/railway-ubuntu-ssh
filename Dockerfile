FROM ubuntu:latest

# Install SSH, Ngrok, dan cURL/jq
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    unzip \
    jq \
    && rm -rf /var/lib/apt-get/lists/*

# Install Ngrok
RUN curl -s https://bin.equinox.io/c/bMR2AQHv547/ngrok-v3-stable-linux-amd64.tgz -o ngrok.tgz \
    && tar -xvzf ngrok.tgz -C /usr/local/bin \
    && rm ngrok.tgz

# Setup Password Root
RUN echo 'root:password123' | chpasswd
RUN mkdir -p /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22

# Start Script (SSH + Ngrok + Auto-Report ke Telegram via Webhook)
CMD service ssh start && ngrok tcp --authtoken $NGROK_AUTHTOKEN 22 > /dev/null & sleep 8 && NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url') && HOST=$(echo $NGROK_URL | sed 's/tcp:\/\/ //' | cut -d: -f1) && PORT=$(echo $NGROK_URL | sed 's/tcp:\/\/ //' | cut -d: -f2) && MSG="🚀 *VPS UBUNTU ONLINE!*%0A%0A🌐 *Host:* \`$HOST\`%0A🔌 *Port:* \`$PORT\`%0A👤 *User:* \`root\`%0A🔑 *Password:* \`password123\`%0A%0A📋 *Command SSH:*%0A\`ssh root@$HOST -p $PORT\`" && curl -s "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$TELEGRAM_CHAT_ID&text=$MSG&parse_mode=Markdown" && tail -f /dev/null
