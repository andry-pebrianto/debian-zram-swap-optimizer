#!/bin/bash
set -e

# Load environment variables from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi
echo ""

# --- ZRAM setup ---
echo "- Installing zram-tools..."
apt update
apt install -y zram-tools
echo ""

echo "- Setup ZRAM..."
if [ -f /etc/default/zramswap ]; then
    cp /etc/default/zramswap /etc/default/zramswap.bak
fi

cat > /etc/default/zramswap <<EOF
ALGO=${ZRAM_ALGO}
PERCENT=${ZRAM_PERCENT}
PRIORITY=${ZRAM_PRIORITY}
EOF
echo ""

echo "- Enabling and restarting zramswap service..."
systemctl enable zramswap
systemctl restart zramswap || systemctl restart zramswap.service
echo ""
# End of ZRAM setup

# --- Swapfile setup ---
echo "- Creating swapfile..."
swapoff /swapfile 2>/dev/null || true

if ! fallocate -l ${SWAP_SIZE_MB}M /swapfile 2>/dev/null; then
    echo ""
    echo "Using fallocate failed, falling back to dd..."
    dd if=/dev/zero of=/swapfile bs=1M count=${SWAP_SIZE_MB} status=progress
    echo ""
fi

chmod 600 /swapfile
mkswap /swapfile
echo ""

echo "- Activating swapfile with lower priority..."
swapon -o pri=${SWAP_PRIORITY} /swapfile
echo ""

echo "- Adding /swapfile entry to /etc/fstab..."
if ! grep -q "/swapfile" /etc/fstab; then
    cp /etc/fstab /etc/fstab.bak
    echo "/swapfile none swap sw,pri=10 0 0" >> /etc/fstab
fi
echo ""
# End of Swapfile setup

# --- Sysctl tuning ---
echo "- Applying sysctl tuning..."
cat > /etc/sysctl.d/99-zram-tweaks.conf <<EOF
vm.swappiness = ${SYSCTL_SWAPPINESS}
vm.vfs_cache_pressure = ${SYSCTL_VFS_CACHE_PRESSURE}
EOF

sysctl --system
echo ""
# End of Sysctl tuning

echo "ZRAM:"
zramctl || true
echo ""

echo "Swapfile:"
swapon --show
echo ""

echo "Sysctl:"
sysctl vm.swappiness vm.vfs_cache_pressure
echo ""

echo "All Done!"