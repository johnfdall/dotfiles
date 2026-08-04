# neomutt + ProtonMail Bridge — per-machine setup

Personal Proton account over online IMAP. Bridge runs locally and speaks
IMAP on `127.0.0.1:1143` / SMTP on `127.0.0.1:1025`; neomutt talks to that.
Credentials come from `pass`, never from a file in the repo.

Work mail (Microsoft 365) is **not** set up here — it needs OAuth2 and is a
separate job. `accounts/` is a directory so a second account can slot in.

## Which packages to stow

    # Linux (Arch)
    stow neomutt gnupg bash systemd tmux nvim ghostty waybar hyprland

    # macOS — no systemd, no Wayland compositor, no status bar
    stow neomutt gnupg bash tmux nvim ghostty

## Dependencies

    # Arch
    sudo pacman -S neomutt protonmail-bridge pass gnupg w3m urlscan pinentry

    # macOS
    brew install neomutt pass gnupg w3m urlscan pinentry-mac
    # Bridge is a GUI app: https://proton.me/mail/bridge

## Steps (same on every machine)

1. **Link the pinentry wrapper into place.** `gpg-agent.conf` must name an
   absolute path (it expands neither `~` nor `$HOME`), and usernames and home
   prefixes differ across these machines, so the config points at a fixed
   system path:

       sudo ln -sfn ~/.gnupg/pinentry-auto /usr/local/bin/pinentry-auto
       gpgconf --kill gpg-agent

   This is first because skipping it makes *everything* touching gpg fail with
   `No pinentry` — including the key generation in the next step.

2. **A GPG key must exist**, because `pass` is encrypted to it. Simplest is to
   generate one locally — the store holds exactly one secret, this machine's
   own Bridge password, so nothing needs sharing between machines:

       gpg --full-generate-key
       gpg --list-secret-keys --keyid-format=long
       pass init <long-key-id>

   **Init by key ID, never by email address.** Proton publishes public keys for
   its own addresses, so `pass init john.fredrik.dall@protonmail.com` can
   resolve to Proton's key rather than yours — silently producing a store you
   can encrypt to but never decrypt. Check the key is listed under
   `--list-secret-keys` before trusting it.

   If you'd rather reuse one key everywhere (worth it if you sign outgoing
   mail — otherwise recipients see a different key per machine):

       ssh -t <other-host> 'gpg --export-secret-keys --armor <id>' | gpg --import
       gpg --edit-key <id>       # trust -> 5 -> y -> save

   The `-t` is required: without a terminal, gpg-agent can't prompt and the
   export fails with *Inappropriate ioctl for device*. Imported keys also start
   untrusted, since ownertrust lives in the trustdb and doesn't travel with the
   key, so `pass insert` fails until trust is set.

   With a locally generated key, set the signing key for this machine in
   `~/.config/neomutt/local.rc` (gitignored, sourced last):

       set pgp_default_key = "<this machine's long key id>"

3. **Log Bridge in.** Use the headless binary on Linux — `protonmail-bridge`
   is a Qt launcher that aborts without a display, which matters over SSH:

       /usr/lib/protonmail/bridge/bridge --cli     # Linux
       # macOS: just open the Bridge app

   At the `>>>` prompt: `login`, then `change mode <n>` to put the account in
   **combined** address mode, then `info`, then `exit`.

   Combined mode is what makes every address on the account share one login
   and one INBOX; in split mode each address is a separate login that sees
   only its own mail. The setting lives in Bridge's local vault, so it is
   **per-installation** and must be set on every machine — `list` shows the
   current mode.

   Give the CLI ~30s after it starts before issuing `change mode`. It has to
   reach the Proton API first, and until it does the account shows `locked`
   and the command fails with `no such user` — while still printing
   "changed to combined". Re-run `list` to confirm it actually took.

4. **Store this machine's mailbox password.** Every Bridge install has its own
   vault and generates its own password, so this is per-machine and the
   password store never needs to be shared between them:

       pass insert proton/bridge

   Paste the password from `info` — first line only, no trailing notes.

5. **Start Bridge.**

       systemctl --user enable --now protonmail-bridge   # Linux
       # macOS: launch the app, set it to open at login

6. `neomutt`.

7. **Wire up the shell.** `~/.bashrc` is not a stow package — it differs too
   much per machine — so these two lines have to be added by hand:

       export GPG_TTY=$(tty)
       [ -r "$HOME/.config/bash/mail.sh" ] && . "$HOME/.config/bash/mail.sh"

   The first gives terminal pinentry a tty to draw on (without it, passphrase
   prompts over SSH fail). The second defines `mail-unlock`; `stow bash` only
   places the file, it can't source it.

After a reboot the GPG key is no longer cached, so Bridge can't unlock its
vault until you run `mail-unlock` once per session.

## Things that will bite you

**Three keychain failures reset Bridge's vault** and log the account out. A
timed-out passphrase prompt counts as a failure. This is why `mail-unlock`
primes the key *before* touching Bridge, and why `pinentry-timeout 0` is set —
walking away from a prompt must not cost an attempt.

**Over SSH, a GUI pinentry is invisible** — it opens on the physical machine's
screen and times out. `pinentry-auto` picks curses vs GUI based on whether
gpg-agent forwarded a `--display` argument, which is the only signal it has
(the agent is a daemon and can't see the client's `$SSH_CONNECTION`).

**Colours are ANSI names, not hex.** neomutt gates `#RRGGBB` on the terminfo
`RGB` flag, which `xterm-ghostty` doesn't set (it only has `Tc`) and
`tmux-256color` doesn't either — every hex line errors out and the file
aborts. Not a loss: ghostty's "Xcode Dark hc" theme already *is* the xcodedark
palette, so the ANSI names resolve to the right colours on every machine,
including over SSH. See the header of `colors.rc`.

**`systemctl --user` needs a login session.** Don't bother with
`loginctl enable-linger` — with no session there's no way to answer the
passphrase prompt, so Bridge just blocks at startup and has to be restarted
anyway once you do log in.
