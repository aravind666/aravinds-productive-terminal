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

# Build dependencies required by asdf when compiling languages (Python, Ruby,
# etc.) from source. Without these, `asdf install python/ruby ...` fails.
echo "Installing build dependencies for asdf language compilation..."
if command -v apt-get &>/dev/null; then
    sudo apt-get install -y build-essential zlib1g-dev libbz2-dev libreadline-dev \
        libsqlite3-dev libssl-dev libffi-dev liblzma-dev
elif command -v dnf &>/dev/null; then
    sudo dnf install -y gcc make zlib-devel bzip2-devel bzip2-libs readline-devel \
        sqlite sqlite-devel openssl-devel libffi-devel xz-devel
elif command -v yum &>/dev/null; then
    sudo yum install -y gcc make zlib-devel bzip2-devel bzip2-libs readline-devel \
        sqlite sqlite-devel openssl-devel libffi-devel xz-devel
fi

# 2. AWS CLI v2 (Official Installer)
echo "--- Step 2: Installing AWS CLI v2 (Official) ---"
if ! command -v aws &>/dev/null; then
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) AWS_ARCH="x86_64" ;;
        aarch64|arm64) AWS_ARCH="aarch64" ;;
        *) AWS_ARCH="" ;;
    esac

    if [ -n "$AWS_ARCH" ]; then
        echo "Downloading AWS CLI v2 installer for $AWS_ARCH..."
        curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" -o /tmp/awscliv2.zip
        unzip -q -o /tmp/awscliv2.zip -d /tmp
        sudo /tmp/aws/install --update
        rm -rf /tmp/awscliv2.zip /tmp/aws
        echo "AWS CLI installed: $(aws --version)"
    else
        echo "❌ Unsupported architecture ($ARCH) for AWS CLI v2. Skipping."
    fi
else
    echo "AWS CLI already installed: $(aws --version)"
fi

# 3. GitHub CLI (Official Repository)
echo "--- Step 3: Installing GitHub CLI (Official) ---"
if ! command -v gh &>/dev/null; then
    if command -v apt-get &>/dev/null; then
        echo "Adding GitHub CLI apt repository..."
        sudo mkdir -p -m 755 /etc/apt/keyrings
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /tmp/githubcli-archive-keyring.gpg
        sudo mv /tmp/githubcli-archive-keyring.gpg /etc/apt/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        sudo mkdir -p -m 755 /etc/apt/sources.list.d
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y gh
    elif command -v dnf &>/dev/null; then
        echo "Adding GitHub CLI dnf repository..."
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        sudo dnf install -y gh --repo gh-cli
    elif command -v yum &>/dev/null; then
        echo "Adding GitHub CLI yum repository..."
        sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
        sudo yum install -y gh
    else
        echo "❌ Unsupported package manager for GitHub CLI installation. Skipping."
    fi
    command -v gh &>/dev/null && echo "GitHub CLI installed: $(gh --version | head -n 1)"
else
    echo "GitHub CLI already installed: $(gh --version | head -n 1)"
fi

# 4. Oh My Zsh & Core Plugins
echo "--- Step 4: Setting up Oh My Zsh & Plugins ---"
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

if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-history-substring-search" ]; then
    echo "Cloning zsh-history-substring-search..."
    git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM_DIR/plugins/zsh-history-substring-search"
fi


# 5. Create Local Bin Folder
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

# 6. Install Productivity Tools (Starship, Zoxide, Fzf, Eza, Bat)
echo "--- Step 5: Installing Modern CLI Tools (Rust & Go Powered) ---"

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

# 7. Version Manager (asdf)
echo "--- Step 6: Installing asdf Version Manager ---"
if [ ! -d "$HOME/.asdf" ]; then
    echo "Cloning asdf..."
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.15.0
fi

# Add language & tool plugins
. "$HOME/.asdf/asdf.sh"
for plugin in python nodejs rust ruby golang java yq jq; do
    if ! asdf plugin list | grep -q "^${plugin}$"; then
        echo "Adding asdf plugin: $plugin"
        asdf plugin add "$plugin" || true
    fi
done

# Install and set global versions for each asdf-managed tool.
# Node.js and Java use their latest LTS release; the rest use latest stable.
echo "Installing and configuring global asdf tool versions..."

echo "Resolving latest Node.js LTS..."
NODEJS_PLUGIN_DIR="$HOME/.asdf/plugins/nodejs"
asdf nodejs update-nodebuild &>/dev/null || true
# The asdf CLI's "cmd" passthrough for plugin subcommands is unreliable across
# asdf versions, so fall back to invoking the plugin's resolve script
# directly, and finally to plain `asdf latest` if all else fails.
NODEJS_VERSION=$(asdf nodejs resolve lts --latest-available 2>/dev/null || true)
if [ -z "$NODEJS_VERSION" ] && [ -x "$NODEJS_PLUGIN_DIR/lib/commands/command-resolve" ]; then
    NODEJS_VERSION=$(bash "$NODEJS_PLUGIN_DIR/lib/commands/command-resolve" lts --latest-available 2>/dev/null || true)
fi
if [ -z "$NODEJS_VERSION" ]; then
    NODEJS_VERSION=$(asdf latest nodejs)
fi
asdf install nodejs "$NODEJS_VERSION"
asdf global nodejs "$NODEJS_VERSION"

echo "Resolving latest Python..."
PYTHON_VERSION=$(asdf latest python)
asdf install python "$PYTHON_VERSION"
asdf global python "$PYTHON_VERSION"

echo "Resolving latest Ruby..."
RUBY_VERSION=$(asdf latest ruby)
asdf install ruby "$RUBY_VERSION"
asdf global ruby "$RUBY_VERSION"

echo "Resolving latest Go..."
GOLANG_VERSION=$(asdf latest golang)
asdf install golang "$GOLANG_VERSION"
asdf global golang "$GOLANG_VERSION"

echo "Resolving latest Rust..."
RUST_VERSION=$(asdf latest rust)
asdf install rust "$RUST_VERSION"
asdf global rust "$RUST_VERSION"

echo "Resolving latest Amazon Corretto LTS (Java)..."
JAVA_VERSION=$(asdf list-all java 2>/dev/null | grep -E '^corretto-(8|11|17|21|25)\.' | tail -n 1)
if [ -z "$JAVA_VERSION" ]; then
    # Fallback: latest non-musl Corretto build available, in case the LTS
    # major list above becomes outdated.
    JAVA_VERSION=$(asdf list-all java 2>/dev/null | grep -E '^corretto-[0-9]' | grep -v musl | tail -n 1)
fi
asdf install java "$JAVA_VERSION"
asdf global java "$JAVA_VERSION"

echo "Resolving latest yq..."
YQ_VERSION=$(asdf latest yq)
asdf install yq "$YQ_VERSION"
asdf global yq "$YQ_VERSION"

echo "Resolving latest jq..."
JQ_VERSION=$(asdf latest jq)
asdf install jq "$JQ_VERSION"
asdf global jq "$JQ_VERSION"

echo "asdf global versions configured:"
asdf current

# 8. Writing Configurations (Starship & Zshrc)
echo "--- Step 7: Writing Shell Configuration Files ---"

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
  zsh-history-substring-search
  colored-man-pages
  command-not-found
  extract
  sudo
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

# --- Zsh Completion Engine ---
autoload -Uz compinit && compinit

# Case-insensitive, partial-word, and substring completion
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'

# Fuzzy match mistyped commands
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Group completions by category with headers
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:messages' format '%F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for: %d%f'

# Interactive arrow-key completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Cache completions for speed
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcompcache"

# Kill command completion shows process list
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# --- Keybindings ---
bindkey '^[[A' history-substring-search-up     # Arrow Up: smart history search
bindkey '^[[B' history-substring-search-down   # Arrow Down: smart history search
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
bindkey '^[[1;5C' forward-word                 # Ctrl+Right: jump word forward
bindkey '^[[1;5D' backward-word                # Ctrl+Left: jump word back
bindkey '^H' backward-kill-word                # Ctrl+Backspace: delete word
bindkey '^ ' autosuggest-accept                # Ctrl+Space: accept autosuggestion

# --- Zsh Options & Settings ---
setopt CORRECT
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

export HISTSIZE=50000
export SAVEHIST=50000
export HISTFILE="$HOME/.zsh_history"
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=242"
EOF


# 9. Bash to Zsh Switch Autostart
echo "--- Step 8: Setting up Zsh Autostart in .bashrc ---"
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
