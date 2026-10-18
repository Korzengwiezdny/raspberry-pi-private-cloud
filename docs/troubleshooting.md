# Troubleshooting case studies

## K3s retained an unavailable IPv6 address

**Symptom:** K3s repeatedly logged `failed to validate secondaryNodeIP`, reporting a global IPv6 address absent from the host's interfaces.

**Evidence:** the node's address list contained a LAN IPv4 address, the stale global IPv6 address and the hostname. The global IPv6 address did not appear in `ip -6 addr`.

**Change:** set the intended LAN IPv4 address in `/etc/rancher/k3s/config.yaml` and restart K3s:

```yaml
node-ip: "<PI_LAN_IP>"
```

The public excerpt uses a placeholder. Preserve other local options and use a stable address. See the [K3s configuration reference](https://docs.k3s.io/installation/configuration).

**Recorded outcome:** after restarting K3s, the node address list contained only the LAN IPv4 address and hostname. The stale IPv6 entry disappeared.

**Limit:** this confirms the address-list correction in the recorded check. It does not prove that intermittent host freezes were resolved.

## Monitoring pods and cluster networking

The investigation found high restart counts for kube-state-metrics and node-exporter. The record gives exit code 1 for kube-state-metrics and 143 (SIGTERM) for node-exporter.

A redacted kube-state-metrics error was:

```text
failed to create client:
Get "https://<KUBERNETES_SERVICE_IP>:443/version":
connect: network is unreachable
```

This supports a cluster network reachability problem at that time. It does not by itself identify the underlying CNI fault or prove that it caused the entire host to freeze. The address-selection fix above was a subsequent diagnostic step.

## Intermittent host unresponsiveness

**Symptom:** Immich, Grafana and SSH became unavailable while the power LED remained on, sometimes after several days of operation.

### Investigation and observations

1. Considered network failure, a kernel hang, memory exhaustion, storage/USB errors, temperature and power.
2. Distinguished normal USB discovery messages after boot from resets, disconnects, I/O errors and filesystem errors.
3. Found that previous-boot journals were missing. Merely creating the journal directory was insufficient because a Raspberry Pi OS drop-in explicitly selected volatile storage.
4. Added a persistent journald override with storage limits, restarted the journal service and flushed it.
5. Checked both SSDs: the record reports SMART PASSED, No Errors Logged and temperatures around 34–37°C.
6. Identified the system disk on a 5000M USB link and backup disk on a 480M link.
7. Disconnected the backup SSD as an isolation test. The user reported another failure with only the system disk attached.

**Conclusion so far:** recurrence without the backup disk weakens the hypothesis that this disk or its adapter alone caused the freezes. Healthy SMART results do not eliminate power, USB bridge, cable, kernel or network problems. The root cause remains unresolved.

### At the next failure

Record the time, workload and recent changes. Compare LAN, Tailscale, SSH and local console availability before rebooting if possible. After reboot, preserve previous-boot logs and the final 1–2 hours of monitoring data.

```sh
journalctl --list-boots
sudo journalctl -b -1 -e
sudo journalctl -k -b -1 --no-pager
vcgencmd get_throttled
vcgencmd measure_temp
free -h
df -h
```

Check for OOM, watchdog, panic, hung tasks, USB resets, I/O errors, filesystem errors, undervoltage and thermal messages. Absence of a log message is not conclusive when the machine hangs before writing it.

## Initial Wi-Fi installation issue

The first Raspberry Pi OS Lite installation had Wi-Fi problems. Recreating the installation from a different laptop was reported to resolve them. That suggests an installation/preparation difference, but does not prove a specific Raspberry Pi Imager or laptop defect.

## K3s memory cgroups

An early K3s issue was addressed by adding `cgroup_memory=1 cgroup_enable=memory` to the existing `/boot/firmware/cmdline.txt` and rebooting. The record reports K3s working afterward. This is a historical change, not a recommendation to overwrite a boot command line on another system.

## EEPROM and the boot chain

The troubleshooting discussion covered EEPROM bootloader → boot order → storage boot partition → kernel → systemd → services. It also distinguished a disk image from an ordinary directory copy. The record does not establish an EEPROM update or system reimage as a successful fix for the recurring freezes.

## Mobile photo uploads

The mobile client later stopped uploading photos. Proposed checks covered Tailscale connectivity, server URL, selected albums, permissions, background restrictions, mobile data, free storage and server logs.

```sh
cd ~/immich-app
docker compose ps
docker compose logs -f immich-server
```

Compare a foreground upload attempt with the server logs. A final cause and resolution are not recorded.
