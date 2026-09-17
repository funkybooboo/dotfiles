# Sibling repo

How this repo relates to the work-machine dotfiles repo and where the two are allowed to diverge.

## The sibling work repo

There is a second dotfiles repo with the same layout for a work machine
(`nate-stott_domo/dotfiles`, Ubuntu rather than Arch). Most files are meant to
match; some are legitimately per-machine -- git and GPG identity, `.ssh/config`,
the secrets backend, and Hyprland itself, since that machine is still on hyprlang
`.conf` while this one uses the Lua config.

Two further classes of difference are deliberate. Anything that cannot work on the
other machine stays put: the NAS sync jobs, btrfs snapshots and the Arch boot and
hardening stack here, the Domo tooling there. And **AI tooling is split on
purpose** -- `pi` and `ollama` belong to this machine, `claude-code` belongs to
the work one, whatever happens to be installed where.

One asymmetry worth naming, because it looks like a gap and is not: the work repo
has a `000590-credential-permissions` migration that chmods a list of credential
files, and this repo deliberately has no equivalent. That migration exists because
fifteen corporate tools there write group-readable credential files, police
nothing, and re-create them on every token refresh. Here the whole surface is
already covered -- ssh refuses a loose private key at use time, gpg polices
`~/.gnupg`, `secretmgr` chmods its own state, and `secretmgr/config.toml` is
tracked in git so it cannot hold a secret. A sweep that never finds anything reads
as protection while protecting against nothing.

Nothing enforces that split, so a fix landed on one side can sit unported
indefinitely. `dotfiles-drift` reports where the two stand:

```bash
dotfiles-drift /path/to/work/dotfiles   # real content differences only
dotfiles-drift --all                    # plus one-sided, guard-only, identical
dotfiles-drift --one-line               # just the counts
dotfiles-drift --scope=home             # only root/home (home,mig,lib,etc,top)
```

It compares tracked files only, and covers `root/home`, `migrations/`,
`root/etc`, `_common.sh` and the top-level files. `flake.lock` is excluded: each
repo bumps its nixpkgs pin on its own schedule.

Migrations are matched on their **slug**, not their number -- the 6-digit prefix
is a per-repo sort key, and `000235` means yazi here and domo-tools there.

Beyond "differs in substance" it separates two harmless kinds. `path-only` is
identical once the home directory is normalised, which is worth fixing because it
makes a file a permanent hand-port for nothing. `guard-only` is identical once the
`_common.sh` source path and the work repo's `is_debian` install guard are
normalised away -- those are correct where they stand, so that bucket is
"correctly different" rather than a to-do list. The counts are not a progress
metric: porting a behaviour into a file that keeps its own distro guard does not
move them.

It needs both clones on the same machine; where the sibling is missing it says so
and exits cleanly, so it is harmless here.

