# Install Software

These scripts work on **Ubuntu Linux**

---

## Automated workflow

1. Run **pre-reboot scripts**:

```bash
./pre-reboot.sh
```

2. Reboot your machine.

3. Run **post-reboot scripts**:

```bash
./post-reboot.sh
```

4. Reboot again (optional, but recommended for some apps).
   You should now have your machine fully set up.

---

### Pre-reboot scripts

These scripts install core system components, drivers, runtimes, and package managers:

* `basic.sh`
* `cuda.sh`
* `container-runtime.sh`
* `package-managers.sh`

---

### Post-reboot scripts

These scripts install user applications, tools, and configure Git/SSH/GPG:

* `java.sh`
* `jetbrains-toolbox.sh`
* `ollama.sh`
* `global-protect.sh`
* `github-desktop.sh`
* `ssh-key.sh`
* `gpg-key.sh`
* `git-repos.sh`
* `signal-desktop.sh`
* `zoom.sh`
* `packages.sh`

---

## Manual workflow

You can run individual scripts if you only want specific components.
For example:

```bash
./installers/java.sh
```

---

## Post workflow run

* Check your shell configuration (`.bashrc` or `fish.config`) for any appended lines.
* Clean things up if necessary (uncomment lines, remove duplicates, etc.).

---

## Notes

### Folder structure

* **`installers/`** – Contains individual installation scripts for each tool or component.

  * Pre-reboot scripts handle system-level setup (drivers, runtimes, package managers).
  * Post-reboot scripts handle user-level applications and configurations (tools, Git/GPG, SSH).

* **`packages/`** – Contains scripts for managing package lists and bulk installations:

  * `packages.sh` – Defines packages to install via APT, Snap, Flatpak, etc.
  * `manage-packages.sh` – Installs the packages defined in `packages.sh`.

* **`utils/`** – Contains helper scripts used by installers:

  * `log.sh` – Consistent logging function.
  * `copy-to-clip-board.sh` – Copies text to the system clipboard.
  * `reboot.sh` – Safely reboots the system.
  * `shell-configs.sh` – Updates shell configuration files.

### Workflow scripts

* `pre-reboot.sh` – Runs all pre-reboot installers. **Requires reboot** after running.
* `post-reboot.sh` – Runs all post-reboot installers. **Should be run after reboot** from pre-reboot phase.
* `README.md` – Documentation for the setup scripts.

### General notes

* All installers are modular and can be run individually if needed.
* Pre-reboot scripts install system-level packages; post-reboot scripts install user-level applications and configurations.
* The workflow ensures your system is fully set up while avoiding conflicts between system and user-level changes.
