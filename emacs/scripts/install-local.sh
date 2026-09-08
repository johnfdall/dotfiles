#!/bin/sh
set -eu
if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
  echo 'This installer targets Apple Silicon macOS.' >&2
  exit 1
fi
emacs_package_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ -e "$HOME/.emacs" ] || [ -L "$HOME/.emacs" ]; then
  echo 'An existing ~/.emacs would override this configuration; move it aside first.' >&2
  exit 1
fi
if [ ! -e "$HOME/.emacs.d" ] && [ ! -L "$HOME/.emacs.d" ]; then
  ln -s "$emacs_package_dir/.emacs.d" "$HOME/.emacs.d"
elif [ "$(readlink "$HOME/.emacs.d")" != "$emacs_package_dir/.emacs.d" ]; then
  echo 'Existing ~/.emacs.d is not this configuration; refusing to overwrite it.' >&2
  exit 1
fi
mkdir -p "$HOME/.local/share/netcoredbg/3.2.0-1092" "$HOME/.local/bin"
if [ ! -x "$HOME/.local/share/netcoredbg/3.2.0-1092/netcoredbg/netcoredbg" ]; then
  emacs_download_dir=$(mktemp -d)
  curl -fL https://github.com/Samsung/netcoredbg/releases/download/3.2.0-1092/netcoredbg-osx-arm64.zip -o "$emacs_download_dir/netcoredbg.zip"
  printf '%s  %s\n' f4fa33b3ff874910cc184b4bb3b9c56d0abdf5c6521cee0b144d7c6e4a6e59ea "$emacs_download_dir/netcoredbg.zip" | shasum -a 256 -c -
  unzip -q "$emacs_download_dir/netcoredbg.zip" 'netcoredbg/*' -d "$HOME/.local/share/netcoredbg/3.2.0-1092"
fi
if [ -L "$HOME/.local/bin/netcoredbg" ] && [ "$(readlink "$HOME/.local/bin/netcoredbg")" = "$HOME/.local/share/netcoredbg/3.2.0-1092/netcoredbg/netcoredbg" ]; then
  unlink "$HOME/.local/bin/netcoredbg"
fi
if [ ! -e "$HOME/.local/bin/netcoredbg" ] && [ ! -L "$HOME/.local/bin/netcoredbg" ]; then
  # A binary symlink breaks netcoredbg's lookup of adjacent libdbgshim.dylib.
  cat > "$HOME/.local/bin/netcoredbg" <<'EOF'
#!/bin/sh
exec "$HOME/.local/share/netcoredbg/3.2.0-1092/netcoredbg/netcoredbg" "$@"
EOF
  chmod +x "$HOME/.local/bin/netcoredbg"
fi
# Mojo: pixi (from the Brewfile) installs the toolchain, LSP and debugger
# into ~/.pixi/envs/mojo and exposes them in ~/.pixi/bin.
if [ ! -x "$HOME/.pixi/bin/mojo" ]; then
  pixi global install mojo -c https://conda.modular.com/max/ -c conda-forge
fi
emacs --batch -Q -l "$emacs_package_dir/scripts/bootstrap.el"
