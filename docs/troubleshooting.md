# Troubleshooting case studies

## K3s and secondaryNodeIP

**Reported problem:** an IPv6-related `secondaryNodeIP` issue in K3s.

**Recorded configuration change:** explicitly set the node's LAN IPv4 address in `/etc/rancher/k3s/config.yaml`.

Sanitized excerpt:

```yaml
# Replace the placeholder with the host's stable LAN IPv4 address.
node-ip: "<PI_LAN_IP>"
```

Preserve other configuration in the file. K3s supports this configuration path; command-line arguments can override file settings. See the [K3s configuration reference](https://docs.k3s.io/installation/configuration).

After a planned service restart, validate:

```sh
sudo systemctl status k3s --no-pager
sudo k3s kubectl get nodes -o wide
sudo journalctl -u k3s -b --no-pager -n 200
```

**Evidence still needed:** the original redacted error, installed K3s version, expected InternalIP, node readiness and whether the error returned after reboot. The configuration change is recorded, but the final verification output is not yet included.

**Lesson:** make node-address selection explicit when automatic selection does not match the intended network. This incident alone does not explain a full host freeze.

## Intermittent server freezes

**Reported symptom:** occasional server unresponsiveness.

**Status:** investigation remains open. There is no documented, proven root cause or measured stability improvement.

The investigation covers:

| Layer | Evidence to collect |
| --- | --- |
| Network | Compare LAN, Tailscale, SSH and local console availability |
| Application | Check Immich and its dependencies independently |
| Kernel and memory | Previous-boot errors, OOM events and filesystem errors |
| USB and storage | USB resets, I/O failures, mount loss and SMART changes |
| Power and thermals | Temperature and throttling indicators |
| Firmware and OS | EEPROM, bootloader, kernel and system-image versions |

SMART can be useful without ruling out the USB cable, enclosure, bridge or power supply. An EEPROM update or a clean OS image should only be described as a fix if a dated comparison supports that conclusion.

### At the next incident

1. Record the time and workload: import, machine learning, backup, transfer or idle.
2. Check whether only one service is unavailable or the host is unreachable.
3. If the host still responds, collect memory, storage, service and kernel status.
4. After reboot, preserve the previous boot's journal promptly.
5. Compare the incident with monitoring data and recent configuration changes.
6. Change one variable at a time and record the observation period.

Keep full diagnostic exports private. Publish short redacted excerpts that support a conclusion.

## Photos not uploading from the phone

**Reported symptom:** the mobile application does not upload photos.

Check whether the app can load the server gallery first. Then inspect selected backup albums, photo permissions, background activity restrictions, mobile-data settings and the upload queue.

On the server:

```sh
cd ~/immich-app
docker compose logs -f immich-server
```

Attempt an upload with the mobile app open and compare its result with the server log. Also check free disk space and container health.

**Status:** troubleshooting steps are recorded; the final cause and resolution are not yet documented.
