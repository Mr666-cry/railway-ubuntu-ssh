FROM ubuntu:latest

# Install SSH server & dependencies
RUN apt-get update && apt-get install -y \
    openssh-server \
    curl \
    && rm -rf /var/lib/apt-get/lists/*

# Fix privilege separation & sshd configuration
RUN mkdir -p /var/run/sshd /run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

EXPOSE 22

# Script Booting: Set password lalu jalankan SSH daemon secara terus-menerus
CMD bash -c " \
  PASS=\${ROOT_PASSWORD:-password123} && \
  echo \"root:\$PASS\" | chpasswd && \
  exec /usr/sbin/sshd -D \
"
