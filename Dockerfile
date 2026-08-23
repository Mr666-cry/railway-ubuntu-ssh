FROM ubuntu:latest

# Install SSH & utilitas
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    && rm -rf /var/lib/apt-get/lists/*

# Konfigurasi SSH
RUN mkdir -p /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22

# Jalankan SSH server di foreground
CMD ["/usr/sbin/sshd", "-D"]
