# NAS sync and gaming

Two unrelated machine-local subsystems: NAS sync timers and the Steam/Proton gaming stack.

## NAS sync

Timers run automatically after `setup.sh`. Manual sync:

```bash
systemctl --user start nas-sync-documents.service
journalctl --user -u nas-sync-documents.service -f
```

Synced dirs: `Documents`, `Music`, `Photos`, `Audiobooks`, `Books`.
Bidirectional with `--delete`.

## Steam gaming

The stack: 000510 (Steam), 000578 (GE-Proton), 000579 (gamescope), 000580
(gamemode). Per-game launch options are NOT synced by Steam between
machines (open upstream request, steam-for-linux #10475), so the canonical
wrapper is recorded here -- and espanso expands `:steamopts` into it
anywhere it is typed:

```
gamescope -W 1920 -H 1080 -f -- gamemoderun %command%
```

- `-W 1920 -H 1080` -- game renders at 1080p; gamescope scales to the panel
- `-f` -- fullscreen
- `gamemoderun` -- engages Feral GameMode (CPU/GPU perf modes) for the run

New-game setup (game Properties dialog):
1. General -> Launch Options: paste the line above
2. Compatibility -> Force: `GE-Proton11-6-x86_64` (dir pinned by 000578)
3. First launch builds the prefix. If a game suddenly dies on launch,
   rename `compatdata/<appid>` -> `<appid>.bak` and relaunch (Steam Cloud
   restores saves) before blaming Steam/Proton versions -- that fixed
   AOE2DE when nothing else did.

| Game | AppID | Compat tool |
|------|------|-------------|
| Age of Empires 2 DE | 813780 | GE-Proton11-6-x86_64 |
| Civ V | 8930 | GE-Proton11-6-x86_64 |

Every `./migrate.sh` run includes a read-only audit (000581) that lists
installed games still missing the wrapper.

Safe to keep in this repo: launch-option strings, appids, tool names (the
table above is the whole set). Never commit: `loginusers.vdf` (auth
tokens), `ssfn*` (Steam Guard). Steam's on-disk state
(`userdata/<accountid>/config/localconfig.vdf` holds launch options;
`CompatToolMapping` in `config/config.vdf` holds tool pins) is
machine/account-specific and rewritten on every Steam exit -- deliberately
untracked; snapshot manually with Steam closed for a full-state restore
point.

