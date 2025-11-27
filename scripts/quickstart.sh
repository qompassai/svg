#!/bin/sh
# /qompassai/svg/scripts/quickstart.sh
# Qompass AI · SVG Quickstart
# Copyright (C) 2025 Qompass AI
######################################
set -eu
IFS=' 	
'
LOCAL_PREFIX="$HOME/.local"
BIN_DIR="$LOCAL_PREFIX/bin"
CONFIG_DIR="$HOME/.config/svg"
DATA_DIR="$HOME/.local/share/svg"
mkdir -p "$BIN_DIR" "$CONFIG_DIR" "$DATA_DIR"
export PATH="$BIN_DIR:$PATH"
detect_platform() {
        OS="unknown"
        ARCH="unknown"
        uname_s=$(uname -s)
        uname_m=$(uname -m)
        case "$uname_s" in
        Linux*) OS="linux" ;;
        Darwin*) OS="macos" ;;
        CYGWIN* | MINGW* | MSYS*) OS="windows" ;;
        esac
        case "$uname_m" in
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="aarch64" ;;
        *) ARCH="$uname_m" ;;
        esac
}
add_path_to_shell_rc() {
        rcfile=$1
        path_line="export PATH=\"$BIN_DIR:\$PATH\""
        if [ -f "$rcfile" ] && ! grep -Fq "$path_line" "$rcfile"; then
                printf '\n# Added by Qompass AI SVG quickstart\n%s\n' "$path_line" >>"$rcfile"
                echo " → Added PATH to $rcfile"
        fi
}
userspace_install() {
        tool="$1"
        recommend="$2"
        fallback="$3"
        prompt_msg="$tool is missing and userspace install will be attempted."
        printf "\n⚠ $prompt_msg\nMethod: %s\nProceed? [Y/n]: " "$recommend"
        read -r resp
        resp=${resp:-Y}
        case "$resp" in
        Y | y)
                echo "[info] Installing $tool..."
                eval "$recommend" || {
                        echo "[warn] Failed userspace install. $fallback"
                }
                ;;
        *)
                echo "[info] Skipped $tool."
                ;;
        esac
}
check_tools() {
        detect_platform
        echo "Checking SVG utilities for $OS ($ARCH)"
        NPM_GLOBAL="$LOCAL_PREFIX/npm-global"
        mkdir -p "$NPM_GLOBAL/bin"
        ensure_tool() {
                tool="$1"
                npm_package="$2"
                download_msg="$3"
                if ! command -v "$tool" >/dev/null 2>&1; then
                        if command -v npm >/dev/null 2>&1; then
                                userspace_install "$tool" "npm install -g $npm_package --prefix=\"$NPM_GLOBAL\"" "$download_msg"
                                export PATH="$NPM_GLOBAL/bin:$PATH"
                                if [ -x "$NPM_GLOBAL/bin/$tool" ]; then
                                        ln -sf "$NPM_GLOBAL/bin/$tool" "$BIN_DIR/$tool"
                                fi
                        else
                                echo "❗ $tool missing and npm is not in your PATH."
                                echo "   $download_msg"
                        fi
                fi
        }
        ensure_tool "svgo" "@svgo/cli" "See https://github.com/svg/svgo or install via npm globally after you have npm."
        ensure_tool "mjcli" "mathjax-node-cli" "See https://github.com/mathjax/mathjax-node-cli or install with npm when available."
        if ! command -v inkscape >/dev/null 2>&1; then
                case "$OS" in
                linux)
                        printf "\nInkscape missing. Download AppImage from https://inkscape.org/release/ or install via flatpak:\n  flatpak install org.inkscape.Inkscape\nProceed to download manually and re-run? [Y/n]: "
                        read -r resp
                        :
                        ;;
                macos)
                        printf "\nInkscape missing. Download from https://inkscape.org/release/mac-os-x/ or install via brew:\n  brew install --cask inkscape\nProceed to download manually and re-run? [Y/n]: "
                        read -r resp
                        :
                        ;;
                windows)
                        echo "Inkscape missing. Get the Windows installer from https://inkscape.org/ and add it to your PATH."
                        ;;
                esac
        fi
        if ! command -v potrace >/dev/null 2>&1; then
                printf "\nPotrace missing. To install userspace binary, see https://potrace.sourceforge.net/download.html (or use system package manager if comfortable).\n"
        fi
        # rsvg-convert: SVG rasterizer
        if ! command -v rsvg-convert >/dev/null 2>&1; then
                printf "\nLibRSVG/rsvg-convert missing (for SVG to PNG or ASCII previews).\n"
                case "$OS" in
                linux) echo "Try: flatpak install org.gnome.Librsvg or install via package manager." ;;
                macos) echo "Try: brew install librsvg" ;;
                windows) echo "Not easily available on Windows as CLI. View SVG in browser instead." ;;
                esac
        fi
        if ! command -v img2txt >/dev/null 2>&1; then
                printf "\nimg2txt (ASCII preview) missing. For Linux/macOS, install libcaca/caca-utils if desired. Not required.\n"
        fi
        echo "✅ SVG user toolchain checks finished."
}
main_menu() {
        printf '\n'
        printf '╭────────────────────────────────────────────╮\n'
        printf '│        Qompass AI · SVG Quick‑Start        │\n'
        printf '╰────────────────────────────────────────────╯\n'
        printf '\nSelect an option:\n'
        printf ' 1) Install/check SVG tools for your system (all userspace)\n'
        printf ' 2) Convert LaTeX to SVG (LaTeX → SVG math with mjcli)\n'
        printf ' 3) Preview an SVG in terminal as ASCII (if tools installed)\n'
        printf ' a) Run all setup steps & suggest PATH updates\n'
        printf ' q) Quit\n\n'
        printf 'Your choice [1]: '
        read -r choice
        choice=${choice:-1}
        case "$choice" in
        1)
                check_tools
                ;;
        2)
                if ! command -v mjcli >/dev/null 2>&1; then
                        userspace_install "mjcli" "npm install -g mathjax-node-cli --prefix=\"$LOCAL_PREFIX/npm-global\"" "See https://github.com/mathjax/mathjax-node-cli"
                        export PATH="$LOCAL_PREFIX/npm-global/bin:$PATH"
                        [ -x "$LOCAL_PREFIX/npm-global/bin/mjcli" ] && ln -sf "$LOCAL_PREFIX/npm-global/bin/mjcli" "$BIN_DIR/mjcli"
                fi
                printf "\nEnter a LaTeX math expression (one line): "
                read -r eqn
                echo "$eqn" | mjcli --svg --math "$(cat)" >"$DATA_DIR/formula.svg"
                echo "→ Saved SVG to $DATA_DIR/formula.svg"
                ;;
        3)
                printf "Enter SVG file path to preview: "
                read -r svgfile
                if [ -f "$svgfile" ] && command -v rsvg-convert >/dev/null 2>&1 && command -v img2txt >/dev/null 2>&1; then
                        rsvg-convert -h 20 "$svgfile" | img2txt -
                else
                        echo "Required tools (rsvg-convert and/or img2txt) not installed or file missing."
                fi
                ;;
        a | A)
                check_tools
                add_path_to_shell_rc "$HOME/.bashrc"
                add_path_to_shell_rc "$HOME/.zshrc"
                add_path_to_shell_rc "$HOME/.profile"
                echo "→ Userspace PATHs suggested. Open a new shell or source your rc file."
                ;;
        q | Q)
                echo "Goodbye!"
                exit 0
                ;;
        *)
                echo "❌ Invalid option."
                main_menu
                ;;
        esac
}
main() {
        main_menu
}
main "$@"
exit 0
