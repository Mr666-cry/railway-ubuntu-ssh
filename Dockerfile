FROM ubuntu:latest

# Install SSH server & cURL
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    && rm -rf /var/lib/apt-get/lists/*

# Konfigurasi SSH agar mengizinkan Login Root & Password Auth
RUN mkdir -p /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22

# Script Booting: Ambil ROOT_PASSWORD dari Railway, set password, lalu start SSH
CMD bash -c " \
  PASS=\${ROOT_PASSWORD:-password123} && \
  echo \"root:\$PASS\" | chpasswd && \
  /usr/sbin/sshd -D \
"
