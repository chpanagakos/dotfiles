# Home storage & backups — runbook

Set up October 2026. Keep this file in `~/dotfiles/docs/` so it travels with the dotfiles repo.

---

## 1. The big picture

```
Desktop (Debian 13)                    NAS "Arxeio" (UGREEN DXP2800)             Offline
~/mathimata, ~/ai, ~/dotfiles  ──22:00──▶  NVMe  /volume1/staging  ──03:00──▶  SSD /volume2/nas-mirror/Backup task1(1)/staging
                                          (snapshots 02:30, keep 14)           (snapshots 04:00, keep 14)
                                                     │
                                                     └──── weekly, by hand ────▶  WD Blue in Akasa dock
```

| Copy | Where | Updated | Protects against |
|---|---|---|---|
| Original | Desktop | Live | — |
| NAS copy 1 | NVMe, `staging` | Nightly 22:00 from desktop | Desktop disk failure |
| NAS copy 2 | Gigabyte SSD, `nas-mirror` | Nightly 03:00 inside the NAS | NVMe failure |
| Snapshots | Both NAS volumes | Daily, 14 kept | Mistaken deletes, ransomware |
| Offline | WD Blue (unplugged) | Weekly, manual | Anything that hits the whole NAS: surge, UGOS bug, ransomware over SMB |
| Off-site | **Not set up yet** | — | Fire, theft |

---

## 2. The NAS

| Item | Value |
|---|---|
| Model | UGREEN DXP2800, device name **Arxeio** |
| Address | **192.168.1.40** (web UI: `http://192.168.1.40:9999`, or find.ugnas.com) |
| OS | UGOS Pro (1.17.0.0095 at setup) |
| CPU / RAM | Intel N100 / 8 GB |
| Admin account | `cpan` |
| Warranty | Until **2028-03-08** (a third-party OS would not void it, per UGREEN) |

### Drives and pools

| Pool | Drive | Volume | Filesystem | Holds |
|---|---|---|---|---|
| 1 | Micron MTFDKBA256TFK NVMe, 256 GB (M.2 slot) | Volume 1, 223 GB | Btrfs | `staging`, apps, `/home/cpan` |
| 2 | GIGABYTE GP-GSTFS31480GNTD SATA SSD, 480 GB (bay 1) | Volume 2, 431 GB | Btrfs | `nas-mirror` |

Both pools are **Basic** (single drive, no RAID). Redundancy comes from the nightly copy plus snapshots, not RAID.

### Shared folders

- `staging` (`/volume1/staging`): the main copy. Contains the old home backups (Photos, Documents, Mathimata, EIRINI, Videos/family, Books, Films, Wallpapers, code…) and `desktop/` (the nightly desktop backup).
- `nas-mirror` (`/volume2/nas-mirror`): the task's copy lives in **`Backup task1(1)/staging/`**. UGOS names the subfolder after the task (the `(1)` was added because an old folder already had the name). **Never rename it** — the task finds its copy by that name. A new task would create another subfolder, i.e. a second full copy. The task does **not** copy symlinks (57 at setup); restore those from `staging` or the Blue.

### Scheduled jobs on the NAS

| Job | App | Time | Settings |
|---|---|---|---|
| `staging` → `nas-mirror` | Sync & Backup ("Backup between storage pools") | 03:00 daily | Mirror backup, task name `Backup task1` |
| Snapshot of `staging` | Snapshot | 02:30 daily | Keep 14 |
| Snapshot of `nas-mirror` | Snapshot | 04:00 daily | Keep 14 |

Apps (Sync & Backup, Snapshot) are installed on Volume 1.

### SSH and security settings

- Control Panel → Terminal: SSH **on**, port **22**, shut down automatically **Never**, SFTP **on**, encryption High.
- "Local network access only": ticked. **May need unticking for Tailscale** — check when setting it up.
- Security → Auto block: 10 failed logins in 5 minutes. If the desktop gets locked out: Security → **Block management**, remove the address. Not known whether blocks expire.
- DoS protection: off (no internet exposure).
- rsync *backup service* (File Service → rsync): **off**. It is a separate daemon; not needed — backups use rsync over SSH.

### The home directory quirk

UGOS's root filesystem is an `overlay` on system storage, so a hand-made `/home/cpan` may vanish on reboot or update. The **Personal Folder** feature (Files app) gives `cpan` a real home on Volume 1. Check: `ssh cpan@192.168.1.40 'df -h ~'` should show 223G, not `overlay`. If the Personal Folder is ever lost (e.g. Volume 1 recreated), SSH key login breaks — re-enable it, then re-run `ssh-copy-id`.

### The rsync path quirk

UGOS passes rsync-over-SSH through its own rsync service. Destination paths must be **`sharename/subfolder`** (e.g. `staging/desktop/`), **not** `/volume1/staging/desktop/` — that gives `invalid path … clientserver.c`.

---

## 3. Desktop → NAS backup

| Item | Value |
|---|---|
| Script | `~/dotfiles/bin/desktop-backup.sh` |
| Setup script | `~/dotfiles/bin/setup-desktop-backup.sh` (idempotent, safe to re-run) |
| Backs up | `~/mathimata`, `~/ai`, `~/dotfiles` → `staging/desktop/` |
| Schedule | systemd **user** timer, 22:00, `Persistent=true`, retries every 10 min on failure (4×) |
| Key | `~/.ssh/nas_backup` (ed25519, no passphrase — **never commit it**) |

**Excluded** (rebuildable): `ai/hf-cache`, `ai/models`, `ai/llama.cpp`, `ai/llama/llama.cpp`, `ai/tmp`, and every `.venv`, `__pycache__`, `.mypy_cache`, `.pytest_cache`, `node_modules`, `.cache`.

`--delete` is on: files deleted on the desktop disappear from the NAS next run, but the NAS snapshots keep them for 14 days.

### Commands

```bash
~/dotfiles/bin/desktop-backup.sh --dry-run        # what would change
systemctl --user start desktop-backup.service     # run now
journalctl --user -u desktop-backup -n 20 --no-pager   # last run's log
systemctl --user list-timers desktop-backup.timer # next run
```

To add a folder: edit `FOLDERS=(…)` in `desktop-backup.sh` (names relative to `$HOME`), dry-run, commit.

### On a new / reformatted system

```bash
sudo apt install rsync openssh-client
git clone <dotfiles remote> ~/dotfiles
~/dotfiles/bin/setup-desktop-backup.sh   # creates a new key if needed, installs it, enables the timer
```

Then remove the old machine's key from the NAS: `ssh cpan@192.168.1.40`, edit `~/.ssh/authorized_keys`, delete stale `desktop-backup@<hostname>` lines.

### Models and venvs (not backed up — how to get them back)

- `~/ai/MODELS.txt` is regenerated before every backup: Hugging Face repos in the cache + GGUF file names and sizes.
- Re-download: `hf download ORG/REPO FILE.gguf --local-dir ~/ai/models/gguf` (gated models: `hf auth login` first).
- Projects with `pyproject.toml` + `uv.lock` (e.g. `~/ai/projects/corpus`): `uv sync` rebuilds `.venv`.
- Old NAS projects without dependency files have `requirements-recovered.txt` (first line is the Python version as a comment): `pip install -r requirements-recovered.txt`.

---

## 4. The offline copy (WD Blue)

| Item | Value |
|---|---|
| Drive | WDC WD20EZRZ-22Z5HB0 (WD Blue 2 TB, CMR, 5400 rpm, ~31,400 h at setup) |
| Format | Plain ext4, **label `blue-offline`**, readable on any Linux |
| Dock | Akasa AK-DK08U3-BK (DuoDock X3), USB 3.0, own power adapter |
| Script | `~/dotfiles/bin/refresh-blue.sh` |

### Weekly routine

1. Dock the Blue, switch the dock on.
2. `~/dotfiles/bin/refresh-blue.sh` → answer `y`, enter sudo password, then UGOS password for `cpan`.
3. Wait for "Done", switch the dock off, let the drive spin down before lifting it. Store it away from the NAS.

### Rules

- **Music lives only on the Blue** (deleted from the NAS). The script excludes `/Music/` so it is never deleted. Never run a plain `rsync --delete` onto the Blue without that exclusion.
- Files deleted or changed on the NAS go to `_deleted/<date>/` on the Blue instead of vanishing. Clear old ones by hand now and then.
- The script refuses to run if a mount failed or the source looks empty (protects against `--delete` wiping the Blue).
- **Akasa clone button**: with two drives docked, one press overwrites one drive with the other, no confirmation. Dock **one drive at a time**.

---

## 5. Restoring

| Lost | Restore from | How |
|---|---|---|
| A file deleted/overwritten in the last 14 days | NAS snapshots | Snapshot app → pick `staging` (or `nas-mirror`) → pick the day → restore/browse. Snapshots live in `/volumeX/@snapshot/` |
| The NVMe died | `nas-mirror` | Replace drive, new Basic pool + Btrfs volume, copy `nas-mirror/Backup task1(1)/staging` → new `staging` (Files → Copy to), then restore the symlinks from the Blue |
| The whole NAS died | WD Blue | Plug into the desktop via the dock; it mounts as a normal ext4 drive (`sudo mount LABEL=blue-offline /mnt/blue`) |
| Something removed from the NAS > 14 days ago | WD Blue `_deleted/` | Look under `/mnt/blue/_deleted/<date>/` |
| Desktop disk died | NAS `staging/desktop/` | `rsync -rlt cpan@192.168.1.40:staging/desktop/ ~/` (or copy over SMB), then `uv sync` in projects, re-download models from `MODELS.txt` |

Verify a copy: compare Properties (bytes, files, folders, hidden items) in the UGOS Files app, or `rsync -rlcni --delete SRC/ DST/` (no output = identical).

---

## 6. Other drives (desktop)

| Drive | State | Use |
|---|---|---|
| TEAM TM8FPW001T NVMe 1 TB | Healthy | Debian system, `/home`, NTFS data partition |
| Samsung 850 EVO 250 GB | — | Windows system drive. Don't touch |
| Kingston SA400S37120G 120 GB SSD | ~4% worn | Wiped (was the NAS's Pool 2) → NTFS data drive for Windows |
| Seagate ST3500418AS 500 GB HDD | **Failing: 297 reallocated sectors**, ~29,700 h | NTFS "Games" drive for Windows. Nothing irreplaceable on it. Retire if reallocated count climbs or pending sectors appear (CrystalDiskInfo on Windows) |

Desktop board: ASUS TUF GAMING B560M-PLUS — 2× rear USB 3.2 **Gen 2 (10 Gbps) Type-A**; the others (incl. the single Type-C) are 5 Gbps. No 20 Gbps ports (so Gen 2x2 drives like the Crucial X10 run at Gen 2 speed).

---

## 7. Health baselines (October 2026)

Re-check every few months. Watch the counters that should stay at zero.

| Drive | Hours | Watch | Baseline |
|---|---|---|---|
| Micron NVMe | 1,962 | Available spare, media errors, unsafe shutdowns | Spare 100%, ~350 GB written, 18 unsafe shutdowns |
| Gigabyte SSD | 6,279 | 231 SSD_Life_Left, 218 CRC | Life 99%, 976 GiB written, CRC 0 |
| WD Blue | 31,380 | 5, 196, 197, 198 (should be 0), 193 load cycles | All 0; 72,034 load cycles (rated 300k) |

UGOS quirk: its "Present value" column is the firmware's normalised score — use the **raw** values ("Advanced" view on the S.M.A.R.T. tab).

Desktop: `sudo smartctl -A /dev/sdX` (smartmontools).

---

## 8. Decisions and plans

- **OS**: kept UGOS. TrueNAS/ZFS gains nothing with mismatched single drives; Debian would mean maintaining the NAS by hand. Revisit only if UGOS blocks something.
- **No RAID**: 2 drives with different roles + snapshots + offline copy beats a mirror here.
- **Optional purchase**: WD Red Plus 4 TB (**WD40EFPX**, CMR, ~€199 on Skroutz in Oct 2026; IronWolf ST4000VN006 equivalent). Only needed if data outgrows the Gigabyte's 480 GB. Avoid SMR, SAS (won't work in the DXP2800) and used server pulls.
- **Dropped from the NAS**: Master's lecture videos, **Music**, downloaded models, venvs. Lectures and Music still exist **only on the Blue**. Music is kept there on purpose (the refresh script never deletes it); at the next refresh the lectures move into `_deleted/<date>/` on the Blue (not destroyed), because they are no longer on the NAS — delete that folder when you're sure.
- **Kept for now**: the old temporary `home` backup (~30 GB) in `staging`. Delete it when space is needed.
- **Git remotes**: not needed on the NAS (project `.git` folders are already in the nightly backup). An off-site remote (GitLab/GitHub/Codeberg) is optional, for off-site code history.

---

## 9. Reminders and gotchas

- **Keep ~20% free** on each Btrfs volume.
- **Snapshots delay freeing space**: deleting a big folder only frees space after its last snapshot expires (14 days), unless you delete snapshots in the Snapshot app.
- **Empty the UGOS recycle bin** after big deletes, or the space isn't freed. Deleting over SMB/SSH may also go through it.
- **Removed drive = "Corrupted" pool** in UGOS. Expected. Never click "repair". Delete the pool entry only when the drive is gone for good (Delete storage pool).
- **Files app can't delete shared folders** from its toolbar — use the shared folder management in UGOS. (Location found: _fill in_)
- **Sync & Backup tasks can't switch mode** (Incremental ↔ Mirror) after creation — delete and recreate. Deleting a task leaves its subfolder in the destination; remove the orphan by hand. When deleting a task, answer **no** to deleting the backed-up data unless you mean it.
- **Shut the NAS down from UGOS** (power icon → Shut down) before removing or adding drives.
- **zsh** doesn't treat `#` as a comment at the prompt; `setopt interactivecomments` in `~/.zshrc` fixes it.
- **UGOS drives on Debian**: UGOS wraps even Basic pools in mdadm (+ maybe LVM); a file manager can't open them. Reformat for plain use; to read one in place, start md arrays read-only first (`echo 1 | sudo tee /sys/module/md_mod/parameters/start_ro`).
- After every **UGOS firmware update**: check SSH key login still works (`ssh -i ~/.ssh/nas_backup cpan@192.168.1.40 true`), and that the four jobs still run.

### Routine checklist

- [ ] **Weekly**: refresh the Blue.
- [ ] **Weekly** (glance): `journalctl --user -u desktop-backup -n 5`; Sync & Backup last run = success; Snapshot apps show new snapshots.
- [ ] **Every few months**: SMART raw values vs. the baselines above; free space on both volumes.
- [ ] **After reinstalling the desktop**: run `setup-desktop-backup.sh`, remove the old key from the NAS.

---

## 10. Still to do

- [ ] SSH from the ThinkPad into the desktop (work + run models on the desktop), with `tmux`.
- [ ] Tailscale on desktop, ThinkPad (and NAS) for access away from home. Check the NAS "Local network access only" setting.
- [ ] Wake-on-LAN for the desktop (the NAS could send the wake signal).
- [ ] Restrict the backup key on the NAS to rsync only.
- [ ] Off-site copy: restic to Hetzner Storage Box or Backblaze B2 (encrypted), and/or a private git remote.
