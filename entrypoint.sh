#!/bin/bash

# Set Password root jika variabel ROOT_PASSWORD ada
if [ -n "$ROOT_PASSWORD" ]; then
    echo "root:$ROOT_PASSWORD" | chpasswd
    echo "🔑 Password root berhasil diubah!"
else
    echo "root:root" | chpasswd
    echo "⚠️ ROOT_PASSWORD tidak ditemukan, menggunakan password bawaan: root"
fi

# Buat banner MOTD murni Ubuntu saat login SSH
cat << 'EOF' > /etc/motd
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.18.15+deb13-cloud-amd64 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
EOF

echo "🚀 Menjalankan OpenSSH Server Daemon..."
# Flag -D penting agar container TIDAK MATI / CLOSED CONNECTION
exec /usr/sbin/sshd -D
