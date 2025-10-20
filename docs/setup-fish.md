To switch your user's default shell from bash to fish without affecting other users, you can use the `chsh` (change shell) command specifically for your user account. Here's how:

1. Confirm the path to the fish shell binary by running:
   ```
   which fish
   ```
   This often returns `/usr/bin/fish` or `/usr/local/bin/fish`.

2. Change your user's default shell with:
   ```
   chsh -s /usr/bin/fish
   ```
   (Replace `/usr/bin/fish` with the path from step 1 if different.)

3. Log out and then log back in for the change to take effect.

This changes the shell only for your user, not for others or root. To verify your shell, run:
```
echo $SHELL
```

If you want fish to run only interactively but keep bash as the login shell, you can alternatively add `exec fish` at the end of your `~/.bashrc` file. This way, bash starts fish on terminal startup but fish is not the system default shell.

Be aware that switching your login shell to fish means you should migrate any environment variable settings or startup scripts from bash (`.bashrc`, `.bash_profile`) to fish's configuration (`~/.config/fish/config.fish`), as fish uses different syntax for shell configurations.

In summary, the safest and easiest method to switch only your user's shell to fish is using:
```
chsh -s /usr/bin/fish
```
and then logging out/in. This method changes just your user's default shell without impacting others or system-wide settings.[1][2][5]

[1](https://fishshell.com/docs/3.0/tutorial.html)
[2](https://www.reddit.com/r/linux4noobs/comments/gp17ik/how_to_make_fish_shell_as_my_default_shell/)
[3](https://fishshell.com/docs/current/)
[4](https://forum.endeavouros.com/t/switching-to-fish-shell/9104)
[5](https://wiki.archlinux.org/title/Fish)
[6](https://stackoverflow.com/questions/53474858/no-im-not-able-to-change-my-default-shell-to-fish-shell)
