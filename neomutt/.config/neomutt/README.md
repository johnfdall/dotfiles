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

1. **A GPG key must exist**, because `pass` is encrypted to it. Either import
   your existing secret key or `gpg --full-generate-key`. The *password store
   contents* do not need syncing — see step 4.

   Then `pass init` it — **by key ID, never by email address**:

       gpg --list-secret-keys --keyid-format=long    # confirm you hold the SECRET key
       pass init <long-key-id>

   Proton publishes public keys for its own addresses, so initialising against
   `john.fredrik.dall@protonmail.com` can resolve to Proton's key instead of
   yours. That silently produces a store you can encrypt to but never decrypt.
   A key ID is unambiguous.

   An imported key also starts untrusted — ownertrust lives in the trustdb and
   doesn't travel with the key — so `pass insert` fails with *"no assurance
   this key belongs to the named user"* until:

       gpg --edit-key <long-key-id>      # trust -> 5 -> y -> save

2. **macOS only — fix the pinentry path.** `gpg-agent.conf` needs an absolute
   path and home directories differ:

       sed -i '' "s|/home/johndall/|$HOME/|" ~/.gnupg/gpg-agent.conf

   (On Linux the committed value is already correct.)
   Then `gpgconf --kill gpg-agent`.

3. **Log Bridge in.** Use the headless binary on Linux — `protonmail-bridge`
   is a Qt launcher that aborts without a display, which matters over SSH:

       /usr/lib/protonmail/bridge/bridge --cli     # Linux
       # macOS: just open the Bridge app

   At the `>>>` prompt: `login`, then `info`, then `exit`.

4. **Store this machine's mailbox password.** Every Bridge install has its own
   vault and generates its own password, so this is per-machine and the
   password store never needs to be shared between them:

       pass insert proton/bridge

   Paste the password from `info` — first line only, no trailing notes.

5. **Start Bridge.**

       systemctl --user enable --now protonmail-bridge   # Linux
       # macOS: launch the app, set it to open at login

6. `neomutt`.

After a reboot the GPG key is no longer cached, so Bridge can't unlock its
vault until you run `mail-unlock` (from the `bash` package) once per session.

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
