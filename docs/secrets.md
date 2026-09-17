# Secrets

How secrets are stored and accessed via secretmgr.

## Secrets

All secrets live in **Proton Pass**, accessed via `secretmgr`.

| Command | Purpose |
|---------|---------|
| `secretmgr init` | Install pass-cli, login |
| `secretmgr get <vault/item> [FIELD]` | Get a secret |
| `secretmgr add <vault/item> KEY=val...` | Add/update |
| `secretmgr copy <vault/item> FIELD` | Copy to clipboard (45s auto-clear) |
| `secretmgr bootstrap` | Deploy all secrets + render templates |
| `secretmgr ssh-add` | Load SSH keys from Proton Pass `SSH` vault |

Vault aliases: `nas`, `api`, `ssh`, `gpg`, `home`, `services`, `subscriptions`,
`identity`, `gaming`, `school`, `projects`, `apply`, `finance`, `aws`.

`secretmgr bootstrap` runs in `setup.sh`. SSH keys load into the agent on
login (`load_on_login = true` in `~/.config/secretmgr/config.toml`).

