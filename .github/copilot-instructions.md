# Copilot instructions for this repo

1. **Project intent**: this repository spins up a two-node SOC lab via Vagrant + VirtualBox—an Ubuntu 22.04 SIEM host running the Wazuh stack (Wazuh manager + Elastic + Kibana) and a Kali attacker box with common pentest tooling.
2. **Topology snapshot**:
   - Host-only `private_network` on the `192.168.56.0/24` range created by VirtualBox.
   - `siem` VM → IP `192.168.56.10`, hostname `siem.local`, 8 GB RAM / 2 vCPUs, extra VRAM, provisioned by `provision/install_wazuh.sh` with the manager IP passed as the first argument (`10.10.0.50` in Vagrantfile).
   - `kali` VM → IP `10.10.0.51`, hostname `kali.local`, 4 GB RAM / 1 vCPU, provisioned via `provision/install_kali_tools.sh`.
3. **Core workflow (non-obvious commands)**:
   - Bring up everything: `vagrant up` (ensure VirtualBox + Vagrant 2.x are installed locally).
   - Targeted lifecycle: `vagrant up siem`, `vagrant halt kali`, `vagrant destroy siem` when you only need one guest.
   - Re-run provisioning after script edits: `vagrant provision siem` (passes the MANAGER_IP argument automatically) or `vagrant provision kali`.
   - Access shells: `vagrant ssh siem` / `kali`; synced host dir `./shared` is available at `/home/vagrant/shared` on both guests.
4. **Provisioning script behavior**:
   - `install_wazuh.sh` (Ubuntu) updates/ upgrades, adds Java 11, then fetches `wazuh-install.sh` from `packages.wazuh.com` (4.8 fallback to 4.x) and executes it with `-a` so the one-liner installs Wazuh manager, Elasticsearch, and Kibana. It enables the `wazuh-manager`, `elasticsearch`, and `kibana` services and opens UFW ports (5601, 9200, 1514, 514) if UFW exists.
   - Expect the Wazuh installer to take several minutes and require ~6 GB disk + high RAM; scripts assume internet connectivity and will fail fast because `set -euo pipefail` is enabled.
   - `install_kali_tools.sh` refreshes Kali, installs `nmap hydra metasploit-framework tcpdump john wireshark nikto`, and runs `msfdb init` (can hang if PostgreSQL packages are mid-config; the script appends `|| true` so provisioning continues).
5. **Customization touchpoints**:
   - Adjust VM resources and network IPs directly inside `Vagrantfile`; keep IPs unique to VirtualBox’s host-only range to avoid collisions.
   - Pass a different manager IP to the SIEM provisioning script by changing the argument array in the Vagrantfile; the script defaults to `127.0.0.1` if no parameter is provided.
   - Extend tooling by editing the shell scripts; remember to keep them idempotent because Vagrant may re-run them.
6. **Troubleshooting hints**:
   - If `wazuh-install.sh` download fails, the script attempts the 4.x fallback; verify with `ls wazuh-install.sh` inside the VM.
   - After provisioning, `systemctl status wazuh-manager kibana elasticsearch` verifies service health; Kibana usually becomes reachable at `http://<siem_ip>:5601` after a short warm-up.
   - For Kali, rerun only the tooling install via `vagrant ssh kali && sudo apt-get install <pkg>`—the script is safe to re-execute thanks to apt checks.
7. **Repo hygiene**:
   - `.gitignore` only excludes `.vagrant/`; everything else—including generated installers—will be tracked unless you add additional ignores.
   - The `shared/` folder is empty by default; use it for artifacts you want available on every guest without extra provisioning.
8. **Documentation gap**: there is no README, so keep these instructions as the authoritative quickstart until more docs are added.

When expanding this lab, mirror the existing Vagrant definitions (resources, provisioning hook, dedicated IP) so new guests stay consistent with the established pattern.
