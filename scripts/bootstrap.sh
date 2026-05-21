#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — Linux Distro Bootstrap Script
# =============================================================================
# Detects the distro, updates the system, installs packages from a config
# file or built-in defaults, sets up common dev tools, and logs everything.
#
# Usage:
#   chmod +x bootstrap.sh
#   sudo ./bootstrap.sh [OPTIONS]
#
# Options:
#   -c, --config FILE    Path to a custom package list file
#   -g, --groups GROUPS  Comma-separated groups to install (e.g. base,dev,gui)
#   -n, --no-upgrade     Skip system upgrade
#   -d, --dry-run        Print what would be done without executing
#   -l, --log FILE       Custom log file path (default: /var/log/bootstrap.log)
#   -h, --help           Show this help message
#
# Package list file format (one package per line, # for comments):
#   # This is a comment
#   [group:base]
#   curl
#   wget
#   [group:dev]
#   git
#   vim
# =============================================================================

set -uo pipefail
IFS=$'\n\t'

# =============================================================================
# CONFIGURATION DEFAULTS
# =============================================================================

LOG_FILE="/var/log/bootstrap.log"
DRY_RUN=false
SKIP_UPGRADE=false
CUSTOM_CONFIG=""
SELECTED_GROUPS="base,dev,cli"
INSTALL_ALL=false

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Counters
PKG_INSTALLED=0
PKG_SKIPPED=0
PKG_FAILED=0

# =============================================================================
# BUILT-IN DEFAULT PACKAGE GROUPS
# =============================================================================

declare -A DEFAULT_PACKAGES

DEFAULT_PACKAGES["base"]="
curl
wget
ca-certificates
gnupg
lsb-release
unzip
zip
tar
gzip
bzip2
xz-utils
rsync
cron
logrotate
sudo
"

DEFAULT_PACKAGES["cli"]="
vim
nano
htop
tree
jq
screen
ncdu
duf
pv
procps
less
man-db
"

DEFAULT_PACKAGES["dev"]="
git
make
build-essential
pkg-config
gdb
strace
ltrace
valgrind
zsh
stow
"

# Installed via their own upstream installers (not distro package manager)
# just, uv, rustup, golang, zoxide are handled in install_external_tools()

# =============================================================================
# CARGO PACKAGES (installed via `cargo install` when the dev group is selected)
# Add one crate name per line. Comments and blank lines are ignored.
# These require rustup/cargo to be present (installed by install_rustup).
# =============================================================================

CARGO_PACKAGES="
# Crates installed via 'cargo install' when the dev group is active.
# One crate name per line; inline # comments and blank lines are ignored.
# Note: ripgrep, fd-find, and bat are intentionally omitted here — they are
# installed faster via the distro package manager in the cli group instead.

# --- file & system ---
du-dust          # intuitive du replacement (dust)

# --- text & data ---
hyperfine        # command-line benchmarking tool

# --- dev productivity ---
cargo-watch      # re-runs cargo commands on file change
tokei            # count lines of code by language
"

DEFAULT_PACKAGES["network"]="
net-tools
iproute2
nmap
netcat-openbsd
tcpdump
traceroute
dnsutils
whois
openssh-client
openssl
"

DEFAULT_PACKAGES["security"]="
fail2ban
apparmor
apparmor-utils
rkhunter
chkrootkit
lynis
"

DEFAULT_PACKAGES["container"]="" # Installed via install_docker() using the official Docker repo

DEFAULT_PACKAGES["gui"]="
xclip
xdotool
"

# =============================================================================
# LOGGING
# =============================================================================

log() {
  local level="$1"
  shift
  local msg="$*"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "${ts} [${level}] ${msg}" >>"$LOG_FILE"
}

info() {
  echo -e "${CYAN}[INFO]${RESET}  $*"
  log INFO "$*"
}
success() {
  echo -e "${GREEN}[OK]${RESET}    $*"
  log OK "$*"
}
warn() {
  echo -e "${YELLOW}[WARN]${RESET}  $*"
  log WARN "$*"
}
error() {
  echo -e "${RED}[ERROR]${RESET} $*" >&2
  log ERROR "$*"
}
header() {
  echo -e "\n${BOLD}${BLUE}==> $*${RESET}"
  log INFO "==> $*"
}

die() {
  error "$*"
  exit 1
}

# =============================================================================
# HELPERS
# =============================================================================

print_help() {
  cat <<EOF
${BOLD}bootstrap.sh${RESET} — Linux Distro Bootstrap Script

${BOLD}USAGE${RESET}
  sudo ./bootstrap.sh [OPTIONS]

${BOLD}OPTIONS${RESET}
  -c, --config FILE    Path to a custom package list file
  -g, --groups GROUPS  Comma-separated groups to install
                       Available built-in groups: base, cli, dev, network,
                       security, container, gui
                       Default: base,dev,cli
  -a, --all            Install all available package groups
  -n, --no-upgrade     Skip system upgrade step
  -d, --dry-run        Print what would be done without executing
  -l, --log FILE       Custom log file path (default: /var/log/bootstrap.log)
  -h, --help           Show this help message

${BOLD}ALWAYS INSTALLED (external/upstream)${RESET}
  rustup, Go, just, uv, zoxide, fzf

${BOLD}CARGO PACKAGES (installed when 'dev' group is selected)${RESET}
  Edit the CARGO_PACKAGES variable near the top of the script to customise.
  Each entry is a crate name; inline # comments are supported.

${BOLD}DOTFILES${RESET}
  If ~/dotfiles exists, GNU Stow will be run for each top-level directory.
  Git config is expected to be managed by your dotfiles repo.

${BOLD}PACKAGE FILE FORMAT${RESET}
  # comment
  [group:base]
  curl
  wget
  [group:dev]
  git

${BOLD}EXAMPLES${RESET}
  sudo ./bootstrap.sh
  sudo ./bootstrap.sh --groups base,dev,network
  sudo ./bootstrap.sh --config ./my-packages.txt --no-upgrade
  sudo ./bootstrap.sh --dry-run --groups base,security
EOF
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    die "This script must be run as root (use sudo)."
  fi
}

init_log() {
  local log_dir
  log_dir="$(dirname "$LOG_FILE")"
  mkdir -p "$log_dir"
  touch "$LOG_FILE"
  chmod 640 "$LOG_FILE"
  log INFO "Bootstrap started — PID $$"
  log INFO "Log: $LOG_FILE"
}

# =============================================================================
# DISTRO DETECTION
# =============================================================================

detect_distro() {
  header "Detecting distribution"

  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    DISTRO_ID="${ID:-unknown}"
    DISTRO_ID_LIKE="${ID_LIKE:-}"
    DISTRO_NAME="${NAME:-Unknown}"
    DISTRO_VERSION="${VERSION_ID:-}"
  else
    die "/etc/os-release not found. Cannot detect distro."
  fi

  info "Detected: ${DISTRO_NAME} ${DISTRO_VERSION} (${DISTRO_ID})"

  # Determine package manager family
  if command -v apt-get &>/dev/null; then
    PKG_FAMILY="debian"
  elif command -v dnf &>/dev/null; then
    PKG_FAMILY="fedora"
  elif command -v yum &>/dev/null; then
    PKG_FAMILY="rhel"
  elif command -v pacman &>/dev/null; then
    PKG_FAMILY="arch"
  elif command -v zypper &>/dev/null; then
    PKG_FAMILY="suse"
  elif command -v apk &>/dev/null; then
    PKG_FAMILY="alpine"
  else
    die "No supported package manager found (apt/dnf/yum/pacman/zypper/apk)."
  fi

  info "Package family: ${PKG_FAMILY}"
  log INFO "Distro: ${DISTRO_ID} | Family: ${PKG_FAMILY}"
}

# =============================================================================
# PACKAGE MANAGER ABSTRACTION
# =============================================================================

pkg_update() {
  info "Updating package index..."
  case "$PKG_FAMILY" in
  debian) run_cmd apt-get update -qq ;;
  fedora) run_cmd dnf check-update -q || true ;;
  rhel) run_cmd yum check-update -q || true ;;
  arch) : ;; # Arch sync+upgrade is done atomically in pkg_upgrade via -Syu
  suse) run_cmd zypper refresh ;;
  alpine) run_cmd apk update ;;
  esac
}

pkg_upgrade() {
  info "Upgrading installed packages..."
  case "$PKG_FAMILY" in
  debian) run_cmd apt-get upgrade -y -qq ;;
  fedora) run_cmd dnf upgrade -y -q ;;
  rhel) run_cmd yum update -y -q ;;
  arch) run_cmd pacman -Syu --noconfirm ;; # -Syu syncs db and upgrades atomically; never split -Sy/-Su
  suse) run_cmd zypper update -y ;;
  alpine) run_cmd apk upgrade ;;
  esac
}

pkg_is_installed() {
  local pkg="$1"
  local rc=0
  case "$PKG_FAMILY" in
  debian) dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed" || rc=$? ;;
  fedora | rhel) rpm -q "$pkg" &>/dev/null || rc=$? ;;
  arch) pacman -Q "$pkg" &>/dev/null || rc=$? ;;
  suse) rpm -q "$pkg" &>/dev/null || rc=$? ;;
  alpine) apk info -e "$pkg" &>/dev/null || rc=$? ;;
  esac
  return $rc
}

pkg_install_one() {
  local pkg="$1"
  case "$PKG_FAMILY" in
  debian) run_cmd apt-get install -y -qq "$pkg" ;;
  fedora) run_cmd dnf install -y -q "$pkg" ;;
  rhel) run_cmd yum install -y -q "$pkg" ;;
  arch) run_cmd pacman -S --noconfirm "$pkg" ;;
  suse) run_cmd zypper install -y "$pkg" ;;
  alpine) run_cmd apk add "$pkg" ;;
  esac
}

# Map common package names across distros
resolve_package_name() {
  local pkg="$1"
  case "$PKG_FAMILY" in
  fedora | rhel)
    case "$pkg" in
    build-essential)
      echo "gcc gcc-c++ make"
      return
      ;;
    netcat-openbsd)
      echo "ncat"
      return
      ;;
    fd-find)
      echo "fd-find"
      return
      ;;
    bat)
      echo "bat"
      return
      ;;
    duf)
      echo ""
      return
      ;; # not in default repos
    lsb-release)
      echo "redhat-lsb-core"
      return
      ;;
    man-db)
      echo "man-db"
      return
      ;;
    xz-utils)
      echo "xz"
      return
      ;;
    ca-certificates)
      echo "ca-certificates"
      return
      ;;
    stow)
      echo "stow"
      return
      ;;
    esac
    ;;
  arch)
    case "$pkg" in
    build-essential)
      echo "base-devel"
      return
      ;;
    netcat-openbsd)
      echo "openbsd-netcat"
      return
      ;;
    fd-find)
      echo "fd"
      return
      ;;
    dnsutils)
      echo "bind"
      return
      ;;
    lsb-release)
      echo "lsb-release"
      return
      ;;
    net-tools)
      echo "net-tools"
      return
      ;;
    xz-utils)
      echo "xz"
      return
      ;;
    ca-certificates)
      echo "ca-certificates"
      return
      ;;
    stow)
      echo "stow"
      return
      ;;
    procps)
      echo "procps-ng"
      return
      ;;
    esac
    ;;
  alpine)
    case "$pkg" in
    build-essential)
      echo "build-base"
      return
      ;;
    netcat-openbsd)
      echo "netcat-openbsd"
      return
      ;;
    fd-find)
      echo "fd"
      return
      ;;
    bat)
      echo "bat"
      return
      ;;
    lsb-release)
      echo ""
      return
      ;;
    man-db)
      echo "man-db"
      return
      ;;
    xz-utils)
      echo "xz"
      return
      ;;
    stow)
      echo "stow"
      return
      ;;
    esac
    ;;
  esac
  echo "$pkg"
}

# =============================================================================
# DRY-RUN WRAPPER
# =============================================================================

run_cmd() {
  if [[ "$DRY_RUN" == true ]]; then
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} $*"
    log DRY-RUN "$*"
  else
    log CMD "$*"
    "$@" 2>&1 | tee -a "$LOG_FILE"
    return "${PIPESTATUS[0]}"
  fi
}

# =============================================================================
# INSTALL PACKAGES
# =============================================================================

install_package() {
  local pkg="$1"
  local resolved
  resolved="$(resolve_package_name "$pkg")"

  # Package was mapped to empty (not available on this distro)
  if [[ -z "$resolved" ]]; then
    warn "Skipping '${pkg}' (not available for ${PKG_FAMILY})"
    ((PKG_SKIPPED++))
    return
  fi

  # Handle space-separated multi-package mappings
  for p in $resolved; do
    local already_installed=false
    if [[ "$DRY_RUN" == false ]]; then
      pkg_is_installed "$p" 2>/dev/null && already_installed=true || true
    fi
    if [[ "$already_installed" == true ]]; then
      info "Already installed: ${p}"
      ((PKG_SKIPPED++))
    else
      info "Installing: ${p}"
      if pkg_install_one "$p"; then
        success "Installed: ${p}"
        ((PKG_INSTALLED++))
      else
        warn "Failed to install: ${p}"
        ((PKG_FAILED++))
      fi
    fi
  done
}

install_group() {
  local group="$1"
  local packages="${DEFAULT_PACKAGES[$group]:-}"

  if [[ -z "$packages" ]]; then
    warn "Unknown group: '${group}' — skipping"
    return
  fi

  header "Installing group: ${group}"
  while IFS= read -r pkg; do
    pkg="$(echo "$pkg" | xargs)" # trim whitespace
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    install_package "$pkg"
  done <<<"$packages"
}

# =============================================================================
# PARSE CUSTOM PACKAGE CONFIG FILE
# =============================================================================

install_from_config() {
  local config="$1"
  [[ -f "$config" ]] || die "Config file not found: ${config}"

  header "Reading package config: ${config}"

  local current_group="custom"
  local selected
  IFS=',' read -ra selected <<<"$SELECTED_GROUPS"

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(echo "$line" | xargs)"
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Group header: [group:name]
    if [[ "$line" =~ ^\[group:(.+)\]$ ]]; then
      current_group="${BASH_REMATCH[1]}"
      continue
    fi

    # Only install if group is selected (or no group filter)
    local in_selected=false
    for g in "${selected[@]}"; do
      if [[ "$g" == "all" || "$g" == "$current_group" ]]; then
        in_selected=true
        break
      fi
    done

    if [[ "$in_selected" == true ]]; then
      install_package "$line"
    fi
  done <"$config"
}

# =============================================================================
# POST-INSTALL CONFIGURATION
# =============================================================================

# =============================================================================
# DOTFILES (GNU STOW)
# =============================================================================

setup_dotfiles() {
  local target_user="${SUDO_USER:-${USER:-}}"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local dotfiles_dir
  dotfiles_dir="$(cd "${script_dir}/.." && pwd)"

  header "Stowing dotfiles"

  if ! command -v stow &>/dev/null; then
    warn "GNU Stow not found — skipping dotfiles setup (install the 'stow' package)"
    return
  fi

  info "Running: stow . in ${dotfiles_dir}"

  if [[ "$DRY_RUN" == false ]]; then
    sudo -u "$target_user" stow --dir="$(dirname "$dotfiles_dir")" --target="$(getent passwd "$target_user" | cut -d: -f6)" "$(basename "$dotfiles_dir")" 2>&1 | tee -a "$LOG_FILE" && success "Dotfiles stowed" || warn "Stow reported conflicts — check output above"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} stow . in ${dotfiles_dir}"
  fi
}

# =============================================================================
# EXTERNAL TOOL INSTALLERS
# =============================================================================

# Install rustup + cargo (used by several tools below)
install_rustup() {
  local target_user="${SUDO_USER:-${USER:-}}"
  header "Installing rustup + Rust toolchain"

  if [[ -z "$target_user" ]]; then
    warn "Cannot determine user for rustup — skipping"
    return
  fi

  if sudo -u "$target_user" bash -c 'command -v rustup &>/dev/null'; then
    info "rustup already installed — skipping"
    return
  fi

  if ! command -v curl &>/dev/null; then
    warn "curl not found — skipping rustup install"
    return
  fi

  if [[ "$DRY_RUN" == false ]]; then
    sudo -u "$target_user" bash -c \
      'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path' \
      2>&1 | tee -a "$LOG_FILE"
    success "rustup installed for ${target_user}"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} curl https://sh.rustup.rs | sh -s -- -y"
  fi
}

# Install Go via official tarball
install_golang() {
  header "Installing Go"

  if ! command -v curl &>/dev/null; then
    warn "curl not found — skipping Go install"
    return
  fi

  local go_version="1.26.1"
  local arch
  arch="$(uname -m)"
  case "$arch" in
  x86_64) arch="amd64" ;;
  aarch64) arch="arm64" ;;
  armv6l) arch="armv6l" ;;
  *)
    warn "Unsupported arch for Go: ${arch}"
    return
    ;;
  esac

  local tarball="go${go_version}.linux-${arch}.tar.gz"
  local url="https://go.dev/dl/${tarball}"
  local install_dir="/usr/local/go"

  if [[ -d "$install_dir" ]]; then
    local current_ver
    current_ver="$("${install_dir}/bin/go" version 2>/dev/null | awk '{print $3}' | sed 's/go//')"
    if [[ "$current_ver" == "$go_version" ]]; then
      info "Go ${go_version} already installed — skipping"
      return
    fi
    info "Replacing Go ${current_ver} → ${go_version}"
  fi

  if [[ "$DRY_RUN" == false ]]; then
    run_cmd curl -fsSL "$url" -o "/tmp/${tarball}"
    run_cmd rm -rf "$install_dir"
    run_cmd tar -C /usr/local -xzf "/tmp/${tarball}"
    rm -f "/tmp/${tarball}"
    # Drop a profile.d snippet so all users get Go in PATH
    cat >/etc/profile.d/golang.sh <<'EOF'
export PATH="$PATH:/usr/local/go/bin"
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
EOF
    success "Go ${go_version} installed to ${install_dir}"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} Would install Go ${go_version} to ${install_dir}"
  fi
}

# Install 'just' (command runner) via cargo or prebuilt binary
install_just() {
  header "Installing just (command runner)"

  if command -v just &>/dev/null; then
    info "just already installed — skipping"
    return
  fi

  if ! command -v curl &>/dev/null; then
    warn "curl not found — skipping just install"
    return
  fi

  if [[ "$DRY_RUN" == false ]]; then
    # Prefer the prebuilt installer over cargo to avoid long compile times
    run_cmd curl --proto '=https' --tlsv1.2 -sSf \
      https://just.systems/install.sh | bash -s -- --to /usr/local/bin
    success "just installed to /usr/local/bin"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} Would install just via just.systems/install.sh"
  fi
}

# Install uv (Python package/project manager by Astral)
install_uv() {
  local target_user="${SUDO_USER:-${USER:-}}"
  header "Installing uv (Python package manager)"

  if ! command -v curl &>/dev/null; then
    warn "curl not found — skipping uv install"
    return
  fi

  if command -v uv &>/dev/null; then
    info "uv already installed — skipping"
  else
    if [[ "$DRY_RUN" == false ]]; then
      curl -LsSf https://astral.sh/uv/install.sh |
        env UV_INSTALL_DIR=/usr/local/bin sh 2>&1 | tee -a "$LOG_FILE"
      success "uv installed to /usr/local/bin"
    else
      echo -e "  ${YELLOW}[DRY-RUN]${RESET} Would install uv via astral.sh/uv/install.sh"
    fi
  fi

  # Install latest Python via uv regardless (idempotent)
  if [[ "$DRY_RUN" == false ]] && command -v uv &>/dev/null; then
    info "Installing latest Python via uv..."
    sudo -u "$target_user" uv python install 2>&1 | tee -a "$LOG_FILE" || true
    success "Latest Python installed via uv"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} Would install latest Python via: uv python install"
  fi
}

# Install zoxide (smart cd replacement)
install_zoxide() {
  header "Installing zoxide"

  if command -v zoxide &>/dev/null; then
    info "zoxide already installed — skipping"
    return
  fi

  if ! command -v curl &>/dev/null; then
    warn "curl not found — skipping zoxide install"
    return
  fi

  if [[ "$DRY_RUN" == false ]]; then
    local arch
    arch="$(uname -m)"
    case "$arch" in
    x86_64) arch="x86_64-unknown-linux-musl" ;;
    aarch64) arch="aarch64-unknown-linux-musl" ;;
    *)
      warn "Unsupported arch for zoxide: ${arch}"
      return
      ;;
    esac
    local latest
    latest="$(curl -sSf https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')"
    if [[ -z "$latest" ]]; then
      warn "Could not determine latest zoxide version — skipping"
      return
    fi
    local url="https://github.com/ajeetdsouza/zoxide/releases/download/v${latest}/zoxide-${latest}-${arch}.tar.gz"
    curl -fsSL "$url" -o /tmp/zoxide.tar.gz
    tar -xzf /tmp/zoxide.tar.gz -C /tmp zoxide
    install -m 755 /tmp/zoxide /usr/local/bin/zoxide
    rm -f /tmp/zoxide.tar.gz /tmp/zoxide
    success "zoxide ${latest} installed to /usr/local/bin"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} Would install zoxide binary to /usr/local/bin"
  fi
}

# Install fzf
install_fzf() {
  local target_user="${SUDO_USER:-${USER:-}}"
  header "Installing fzf"

  if command -v fzf &>/dev/null; then
    info "fzf already installed — skipping"
    return
  fi

  if ! command -v git &>/dev/null; then
    warn "git not found — skipping fzf install"
    return
  fi

  if [[ "$DRY_RUN" == false ]]; then
    local fzf_dir="/opt/fzf"
    run_cmd git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    run_cmd "${fzf_dir}/install" --bin # installs binary only, no shell config
    run_cmd ln -sf "${fzf_dir}/bin/fzf" /usr/local/bin/fzf
    success "fzf installed to /usr/local/bin/fzf"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} Would install fzf via github.com/junegunn/fzf"
  fi
}

# Set zsh as the default shell for the invoking user
set_default_shell_zsh() {
  local target_user="${SUDO_USER:-${USER:-}}"
  header "Setting zsh as default shell for ${target_user}"

  if [[ -z "$target_user" ]]; then
    warn "Cannot determine user — skipping shell change"
    return
  fi

  local zsh_path
  zsh_path="$(command -v zsh 2>/dev/null || true)"
  if [[ -z "$zsh_path" ]]; then
    warn "zsh not found in PATH — skipping (was it installed?)"
    return
  fi

  # Ensure zsh is in /etc/shells
  if ! grep -qF "$zsh_path" /etc/shells; then
    echo "$zsh_path" >>/etc/shells
    info "Added ${zsh_path} to /etc/shells"
  fi

  local current_shell
  current_shell="$(getent passwd "$target_user" | cut -d: -f7)"
  if [[ "$current_shell" == "$zsh_path" ]]; then
    info "${target_user} already uses zsh — skipping"
    return
  fi

  if [[ "$DRY_RUN" == false ]]; then
    run_cmd chsh -s "$zsh_path" "$target_user"
    success "Default shell set to ${zsh_path} for ${target_user}"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} Would run: chsh -s ${zsh_path} ${target_user}"
  fi
}

install_cargo_packages() {
  local target_user="${SUDO_USER:-${USER:-}}"
  header "Installing cargo packages"

  local cargo_bin
  cargo_bin="$(sudo -u "$target_user" bash -c 'source "$HOME/.cargo/env" 2>/dev/null; command -v cargo' 2>/dev/null || true)"

  if [[ -z "$cargo_bin" ]]; then
    warn "cargo not found for ${target_user} — skipping cargo installs (was rustup installed?)"
    return
  fi

  while IFS= read -r line; do
    # Strip inline comments and whitespace
    local crate
    crate="$(echo "$line" | sed 's/#.*//' | xargs)"
    [[ -z "$crate" ]] && continue

    info "cargo install: ${crate}"
    if [[ "$DRY_RUN" == true ]]; then
      echo -e "  ${YELLOW}[DRY-RUN]${RESET} cargo install ${crate}"
    else
      if sudo -u "$target_user" bash -c \
        "source \"\$HOME/.cargo/env\" 2>/dev/null; cargo install --quiet '${crate}'" \
        2>&1 | tee -a "$LOG_FILE"; then
        success "cargo: installed ${crate}"
        ((PKG_INSTALLED++))
      else
        warn "cargo: failed to install ${crate}"
        ((PKG_FAILED++))
      fi
    fi
  done <<<"$CARGO_PACKAGES"
}

install_external_tools() {
  header "Installing external/upstream tools"
  install_rustup
  install_golang
  install_just
  install_uv
  install_zoxide
  install_fzf
}

install_docker() {
  header "Installing Docker (official repo)"

  if command -v docker &>/dev/null; then
    info "Docker already installed — skipping"
    # Still ensure user is in docker group
    if [[ -n "${SUDO_USER:-}" ]]; then
      usermod -aG docker "$SUDO_USER" 2>/dev/null || true
    fi
    return
  fi

  if [[ "$PKG_FAMILY" != "debian" ]]; then
    warn "Official Docker repo install only supported for Debian/Ubuntu — skipping"
    return
  fi

  if [[ "$DRY_RUN" == false ]]; then
    # Install dependencies
    run_cmd apt-get install -y -qq ca-certificates curl gnupg

    # Add Docker GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Detect distro for repo URL (handles Ubuntu too)
    local distro
    distro="$(. /etc/os-release && echo "$ID")"
    local codename
    codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"
    local arch
    arch="$(dpkg --print-architecture)"

    # Add Docker apt repo
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${distro} ${codename} stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

    run_cmd apt-get update -qq
    run_cmd apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable service
    run_cmd systemctl enable docker
    run_cmd systemctl start docker || true # May fail in WSL — non-fatal

    # Add invoking user to docker group
    if [[ -n "${SUDO_USER:-}" ]]; then
      run_cmd usermod -aG docker "$SUDO_USER"
      success "Added ${SUDO_USER} to docker group"
    fi

    success "Docker CE installed from official repo"
  else
    echo -e "  ${YELLOW}[DRY-RUN]${RESET} Would add Docker apt repo and install docker-ce"
  fi
}

configure_vim_defaults() {
  header "Writing /etc/vim/vimrc.local defaults"
  local vimrc="/etc/vim/vimrc.local"
  mkdir -p "$(dirname "$vimrc")"

  if [[ "$DRY_RUN" == false ]]; then
    cat >"$vimrc" <<'VIMRC'
" bootstrap.sh system-wide vim defaults
set nocompatible
set backspace=indent,eol,start
set history=1000
set ruler
set showcmd
set incsearch
set hlsearch
set number
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set laststatus=2
syntax on
filetype plugin indent on
VIMRC
    success "Vim defaults written to ${vimrc}"
  else
    info "[DRY-RUN] Would write vim defaults to ${vimrc}"
  fi
}

setup_unattended_upgrades() {
  if [[ "$PKG_FAMILY" == "debian" ]]; then
    header "Setting up unattended-upgrades"
    run_cmd apt-get install -y -qq unattended-upgrades
    echo 'unattended-upgrades unattended-upgrades/enable_auto_updates boolean true' | debconf-set-selections
    run_cmd dpkg-reconfigure -f noninteractive unattended-upgrades
    success "Unattended upgrades configured"
  fi
}

# =============================================================================
# SUMMARY REPORT
# =============================================================================

print_summary() {
  local elapsed=$((SECONDS))
  echo ""
  echo -e "${BOLD}${BLUE}╔══════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${BLUE}║        Bootstrap Summary             ║${RESET}"
  echo -e "${BOLD}${BLUE}╚══════════════════════════════════════╝${RESET}"
  echo -e "  ${GREEN}Installed:${RESET}  ${PKG_INSTALLED} package(s)"
  echo -e "  ${YELLOW}Skipped:${RESET}    ${PKG_SKIPPED} package(s)"
  echo -e "  ${RED}Failed:${RESET}     ${PKG_FAILED} package(s)"
  echo -e "  Time:       ${elapsed}s"
  echo -e "  Log:        ${LOG_FILE}"
  if [[ "$DRY_RUN" == true ]]; then
    echo -e "  ${YELLOW}Mode: DRY-RUN — no changes were made${RESET}"
  fi
  echo ""

  if [[ $PKG_FAILED -gt 0 ]]; then
    warn "Some packages failed to install. Check the log: ${LOG_FILE}"
  else
    success "Bootstrap complete!"
  fi
}

# =============================================================================
# ARGUMENT PARSING
# =============================================================================

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -c | --config)
      CUSTOM_CONFIG="$2"
      shift 2
      ;;
    -g | --groups)
      SELECTED_GROUPS="$2"
      shift 2
      ;;
    -a | --all)
      INSTALL_ALL=true
      shift
      ;;
    -n | --no-upgrade)
      SKIP_UPGRADE=true
      shift
      ;;
    -d | --dry-run)
      DRY_RUN=true
      shift
      ;;
    -l | --log)
      LOG_FILE="$2"
      shift 2
      ;;
    -h | --help)
      print_help
      exit 0
      ;;
    *)
      die "Unknown option: $1 (use --help for usage)"
      ;;
    esac
  done
}

# =============================================================================
# MAIN
# =============================================================================

main() {
  parse_args "$@"
  require_root
  init_log

  echo -e "${BOLD}${BLUE}"
  echo "  ██████╗  ██████╗  ██████╗ ████████╗███████╗████████╗██████╗  █████╗ ██████╗ "
  echo "  ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗"
  echo "  ██████╔╝██║   ██║██║   ██║   ██║   ███████╗   ██║   ██████╔╝███████║██████╔╝"
  echo "  ██╔══██╗██║   ██║██║   ██║   ██║   ╚════██║   ██║   ██╔══██╗██╔══██║██╔═══╝ "
  echo "  ██████╔╝╚██████╔╝╚██████╔╝   ██║   ███████║   ██║   ██║  ██║██║  ██║██║     "
  echo "  ╚═════╝  ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     "
  echo -e "${RESET}"
  echo -e "  Linux System Bootstrap  •  $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  detect_distro

  # Update package index
  pkg_update

  # Optional full upgrade
  if [[ "$SKIP_UPGRADE" == false ]]; then
    header "Upgrading system packages"
    pkg_upgrade
  else
    info "Skipping system upgrade (--no-upgrade)"
  fi

  # Install packages
  if [[ -n "$CUSTOM_CONFIG" ]]; then
    if [[ "$INSTALL_ALL" == true ]]; then
      warn "--all is ignored when --config is used"
    fi
    install_from_config "$CUSTOM_CONFIG"
  else
    if [[ "$INSTALL_ALL" == true ]]; then
      SELECTED_GROUPS="base,cli,dev,network,security,container,gui"
    fi
    header "Installing selected groups: ${SELECTED_GROUPS}"
    IFS=',' read -ra groups <<<"$SELECTED_GROUPS"
    for group in "${groups[@]}"; do
      group="$(echo "$group" | xargs)"
      install_group "$group"
    done
  fi

  # Post-install configuration
  install_external_tools
  if echo "$SELECTED_GROUPS" | grep -q "dev"; then
    install_cargo_packages
  fi
  set_default_shell_zsh
  configure_vim_defaults
  setup_dotfiles

  # Conditional service setup
  if echo "$SELECTED_GROUPS" | grep -q "container"; then
    install_docker
  fi
  if [[ "$PKG_FAMILY" == "debian" ]]; then
    setup_unattended_upgrades
  fi

  print_summary
}

main "$@"
