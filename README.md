# 🚀 aravinds-productive-terminal

A complete, distro-agnostic, and single-command shell environment installer that sets up a highly-productive Zsh, Starship custom theme, modern CLI tools, and the `asdf` runtime manager on any WSL or Linux system.

---

## 🛠️ Features Included

1. **Zsh & Oh My Zsh Framework:** Ready to run with autocompletions and highlighting.
2. **High-Contrast Rainbow Prompt:** Custom Starship theme featuring left/right segmented status bars.
3. **Modern CLI Tool Suite:**
   * **`zoxide` (`z`)** – Smarter directory jumping.
   * **`fzf` (`Ctrl+R`)** – Interactive fuzzy search.
   * **`eza` (`ls`)** – Beautiful colored listings with file icons and Git integration.
   * **`bat` (`cat`)** – Syntax-highlighted viewer.
4. **asdf Version Manager:** Ready-to-go environment for Python, Node.js, Rust, Ruby, Go, and Java.
5. **Interactive Autostart:** Auto-launches Zsh for WSL interactive sessions.
6. **Optional Git Code Signing:** Automated setup of SSH-based commit signing.

---

## 🚀 One-Command Installation

Run this single command in your terminal to download and run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/username/aravinds-productive-terminal/main/install.sh | bash
```

*Note: If you have cloned the repository locally, you can run it directly:*
```bash
bash install.sh
```

---

## 🎨 Nerd Font Requirement
To render the Powerline segments (``, ``, ``, ``) and file/folder icons correctly, you **must** configure your terminal emulator to use a **Nerd Font**:
* Recommended: [Fira Code Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) or [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases).
* Update settings: Terminal Settings -> Profile (e.g. Ubuntu/Oracle) -> Appearance -> Set **Font face** to your Nerd Font.
