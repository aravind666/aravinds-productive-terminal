#!/bin/bash
# ==============================================================================
# aravinds-productive-terminal Installer
# Multi-distro compatibility: Ubuntu/Debian and Oracle Linux/RHEL/Rocky
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo "🌟 Installing Aravinds Productive Terminal Environment 🌟"
echo "=========================================================="

# 1. Distro Detection & Dependency Installation
echo "--- Step 1: Installing Base System Packages ---"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
else
    DISTRO="unknown"
fi

echo "Detected distribution: $DISTRO"

# Function to check and install dependencies
install_deps() {
    if command -v apt-get &>/dev/null; then
        echo "Updating apt cache and installing dependencies..."
        sudo apt-get update
        sudo apt-get install -y zsh git curl tar unzip
    elif command -v dnf &>/dev/null; then
        echo "Installing dependencies via dnf..."
        sudo dnf install -y zsh git curl tar unzip
    elif command -v yum &>/dev/null; then
        echo "Installing dependencies via yum..."
        sudo yum install -y zsh git curl tar unzip
    else
        echo "❌ Error: Supported package manager (apt/dnf/yum) not found."
        echo "Please manually install: zsh, git, curl, tar, unzip"
        exit 1
    fi
}

# Install dependencies if missing
if ! command -v zsh &>/dev/null || ! command -v git &>/dev/null || ! command -v curl &>/dev/null; then
    install_deps
else
    echo "Base system dependencies (zsh, git, curl) already installed."
fi

# 2. Oh My Zsh & Core Plugins
echo "--- Step 2: Setting up Oh My Zsh & Plugins ---"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Downloading and installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# Clone Zsh custom plugins
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM_DIR/plugins"

if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    echo "Cloning zsh-autosuggestions..."
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    echo "Cloning zsh-syntax-highlighting..."
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
fi

# 3. Create Local Bin Folder
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# 4. Install Productivity Tools (Starship, Zoxide, Fzf, Eza, Bat)
echo "--- Step 3: Installing Modern CLI Tools (Rust & Go Powered) ---"

# Starship Prompt
echo "Installing Starship Prompt..."
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$HOME/.local/bin" --yes

# Zoxide
echo "Installing Zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Fzf
if [ ! -d "$HOME/.fzf" ]; then
    echo "Installing Fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all
fi

# Eza (Query Github Releases)
if [ ! -f "$HOME/.local/bin/eza" ]; then
    echo "Installing Eza..."
    EZA_URL=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep -o -E "https://github.com/eza-community/eza/releases/download/[^\"]*x86_64-unknown-linux-gnu.tar.gz" | head -n 1)
    curl -L "$EZA_URL" -o /tmp/eza.tar.gz
    tar -xzf /tmp/eza.tar.gz -C /tmp
    mv /tmp/eza "$HOME/.local/bin/eza"
    chmod +x "$HOME/.local/bin/eza"
    rm -f /tmp/eza.tar.gz
fi

# Bat (Query Github Releases)
if [ ! -f "$HOME/.local/bin/bat" ]; then
    echo "Installing Bat..."
    BAT_URL=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -o -E "https://github.com/sharkdp/bat/releases/download/[^\"]*x86_64-unknown-linux-musl.tar.gz" | head -n 1)
    curl -L "$BAT_URL" -o /tmp/bat.tar.gz
    tar -xzf /tmp/bat.tar.gz -C /tmp
    mv /tmp/bat-*/bat "$HOME/.local/bin/bat"
    chmod +x "$HOME/.local/bin/bat"
    rm -rf /tmp/bat-* /tmp/bat.tar.gz
fi

# 5. Version Manager (asdf)
echo "--- Step 4: Installing asdf Version Manager ---"
if [ ! -d "$HOME/.asdf" ]; then
    echo "Cloning asdf..."
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.15.0
fi

# Add language plugins
. "$HOME/.asdf/asdf.sh"
for plugin in python nodejs rust ruby golang java; do
    if ! asdf plugin list | grep -q "$plugin"; then
        echo "Adding asdf plugin: $plugin"
        asdf plugin add "$plugin" || true
    fi
done

# 6. Writing Configurations (Starship & Zshrc)
echo "--- Step 5: Writing Shell Configuration Files ---"

# Write starship.toml
mkdir -p "$HOME/.config"
cat << 'EOF' > "$HOME/.config/starship.toml"
"$schema" = 'https://starship.rs/config-schema.json'

add_newline = false

format = """
[](#303030)\
$os\
$username\
[](bg:#1d80ce fg:#303030)\
$directory\
[](bg:#4e9a06 fg:#1d80ce)\
$git_branch\
$git_status\
[](fg:#4e9a06)\
$line_break\
$character"""

right_format = """
[](#c4a000)\
$cmd_duration\
[](fg:#ce5c00 bg:#c4a000)\
$memory_usage\
[](fg:#d3d7cf bg:#ce5c00)\
$time\
[ ](fg:#d3d7cf)"""

[os]
disabled = false
style = "bg:#303030 fg:#ffffff"
format = "[$symbol]($style)"

[os.symbols]
Linux = "🐧 "
Redhat = "🐧 "
RedHatEnterprise = "🐧 "
CentOS = "🐧 "
Debian = "🐧 "
Ubuntu = "🐧 "
OracleLinux = "🐙 "

[username]
show_always = true
style_user = "bg:#303030 fg:#ffffff"
style_root = "bg:#303030 fg:#ffffff"
format = "[$user]($style)"

[directory]
style = "bg:#1d80ce fg:#ffffff bold"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:#4e9a06 fg:#000000"
format = '[[ $symbol $branch ](fg:#000000 bg:#4e9a06)]($style)'

[git_status]
style = "bg:#4e9a06 fg:#000000"
format = '[[($all_status$ahead_behind )](fg:#000000 bg:#4e9a06)]($style)'

[cmd_duration]
show_milliseconds = true
style = "bg:#c4a000 fg:#000000"
format = "[[  $duration ](fg:#000000 bg:#c4a000)]($style)"

[memory_usage]
disabled = false
threshold = -1
style = "bg:#ce5c00 fg:#ffffff"
symbol = "󰍛 "
format = "[[ $symbol$ram ](fg:#ffffff bg:#ce5c00)]($style)"

[time]
disabled = false
time_format = "%R"
style = "bg:#d3d7cf fg:#000000"
format = "[[  $time ](fg:#000000 bg:#d3d7cf)]($style)"

[line_break]
disabled = false

[character]
disabled = false
success_symbol = '[❯](bold fg:#4e9a06) '
error_symbol = '[❯](bold fg:#cc0000) '
vimcmd_symbol = '[❮](bold fg:#4e9a06) '
vimcmd_replace_one_symbol = '[❮](bold fg:#ce5c00) '
vimcmd_replace_symbol = '[❮](bold fg:#ce5c00) '
vimcmd_visual_symbol = '[❮](bold fg:#c4a000) '
EOF

# Write .zshrc
cat << 'EOF' > "$HOME/.zshrc"
# --- Oh My Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# --- System Paths ---
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# --- Version Management (asdf) ---
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  . "$HOME/.asdf/asdf.sh"
fi

# --- Tool Initializations ---
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if [ -f "$HOME/.fzf.zsh" ]; then
  source "$HOME/.fzf.zsh"
fi

# --- Custom Aliases ---
if command -v eza &>/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza -la --icons --git --group-directories-first"
  alias tree="eza --tree --icons"
fi

if command -v bat &>/dev/null; then
  alias cat="bat"
fi

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias g="git"
alias gs="git status"
alias gd="git diff"
alias gp="git pull"
alias gc="git commit -m"
alias ga="git add"
alias gco="git checkout"
alias gl="git log --oneline --graph --decorate -n 10"

# --- Zsh Options & Settings ---
setopt CORRECT
setopt SHARE_HISTORY
setopt APPEND_HISTORY

export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=242"
EOF

# 7. Bash to Zsh Switch Autostart
echo "--- Step 6: Setting up Zsh Autostart in .bashrc ---"
AUTOSTART_BLOCK='
# Automatically switch to zsh for interactive shells
if [ -t 1 ] && [ -x /usr/bin/zsh ]; then
    exec /usr/bin/zsh -l
fi
'

if ! grep -q "Automatically switch to zsh" "$HOME/.bashrc"; then
    echo "$AUTOSTART_BLOCK" >> "$HOME/.bashrc"
    echo "Zsh autostart appended to .bashrc."
else
    echo "Zsh autostart block already exists in .bashrc."
fi

echo "=========================================================="
echo "🎉 aravinds-productive-terminal Setup Complete! 🎉"
echo "=========================================================="
echo "To activate the environment immediately, run:"
echo "    exec zsh"
echo "--------------------------------------------------------"
echo "⚠️  Important Font Notice:"
echo "This layout requires a Nerd Font installed on your system"
echo "(e.g., Fira Code Nerd Font, JetBrains Mono Nerd Font)"
echo "Please set your terminal font to see the symbols correctly."
echo "=========================================================="
