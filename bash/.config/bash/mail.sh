# mail-unlock -- unlock the GPG key ProtonMail Bridge needs, then (re)start it.
#
# Bridge keeps its vault key in `pass`, encrypted to your GPG key, so it cannot
# serve IMAP until that key is decryptable. After a reboot the gpg-agent cache
# is empty, which is why this is a per-boot step rather than something the
# systemd unit can do on its own.
#
# Priming the agent *before* starting Bridge is deliberate: Bridge treats a
# keychain timeout as a vault failure and resets the vault -- logging the
# account out -- after three of them. A passphrase typo here costs nothing.

mail-unlock() {
	local key listener=127.0.0.1:1143 i

	# Prime with the exact entry Bridge itself decrypts, so a success here
	# genuinely means Bridge will get in.
	key=$(find ~/.password-store/docker-credential-helpers \
		-name 'bridge-vault-key.gpg' -print -quit 2>/dev/null)
	if [[ -z $key ]]; then
		echo "mail-unlock: no bridge vault key in the password store." >&2
		echo "             Has Bridge ever been set up on this machine?" >&2
		return 1
	fi

	# Terminal pinentry draws on the tty named here; without it, prompting
	# over SSH fails.
	if [[ -t 0 ]]; then
		GPG_TTY=$(tty)
		export GPG_TTY
	fi

	if ! gpg -q --batch --no-tty -d -o /dev/null "$key" 2>/dev/null &&
		! gpg -q -d -o /dev/null "$key"; then
		echo "mail-unlock: passphrase not accepted; Bridge not touched." >&2
		return 1
	fi

	if command -v systemctl >/dev/null 2>&1; then
		systemctl --user restart protonmail-bridge || return 1
	else
		# macOS: Bridge runs as the GUI app or a launchd agent, not a user
		# unit. The key is unlocked now, so starting it won't prompt.
		echo "mail-unlock: key unlocked; start Proton Bridge yourself" >&2
	fi

	# bash's /dev/tcp works on both Linux and macOS -- unlike `ss`, which
	# doesn't exist there.
	for i in $(seq 1 30); do
		if (exec 3<>"/dev/tcp/${listener%:*}/${listener##*:}") 2>/dev/null; then
			echo "mail-unlock: bridge ready on $listener"
			return 0
		fi
		sleep 1
	done

	echo "mail-unlock: bridge did not come up within 30s." >&2
	echo "             journalctl --user -u protonmail-bridge -n 30" >&2
	return 1
}
