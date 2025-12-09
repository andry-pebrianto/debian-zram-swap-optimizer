# debian-zram-swap-optimizer

### Featuring

- ZRAM (compressed RAM) for improved memory performance
- Swapfile creation with configurable size and priority
- Sysctl tuning for swappiness and cache pressure

### How to use

- Clone this repository.
- Adjust the values in the `.env` file according to your preferences.
- Make the setup script executable: `sudo chmod +x setup-zram-swap.sh`
- Run the setup script: `sudo ./setup-zram-swap.sh`

### Verify everything is running and permanent

- Check ZRAM status

```bash
zramctl
```

- Check Swap status

```bash
swapon --show
```

- Check Sysctl settings

```bash
sysctl vm.swappiness vm.vfs_cache_pressure
```

- Verify ZRAM service is enabled (permanent)

```bash
systemctl status zramswap
```

- Verify Swapfile entry in /etc/fstab (permanent)

```bash
grep swapfile /etc/fstab
```

- Verify Sysctl configuration file exists (permanent)

```bash
cat /etc/sysctl.d/99-zram-tweaks.conf
```
