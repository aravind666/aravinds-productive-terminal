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
4. **Official Cloud & VCS Tooling:** [AWS CLI v2](https://docs.aws.amazon.com/cli/) and [GitHub CLI (`gh`)](https://cli.github.com/) installed from their official sources (not asdf), always kept current via each vendor's own update path.
5. **asdf Version Manager:** Automatically installs and sets **global** versions for:
   * **Node.js** – latest LTS
   * **Java** – latest Amazon Corretto LTS
   * **Python, Ruby, Go, Rust** – latest stable
   * **`yq`, `jq`** – latest
6. **Interactive Autostart:** Auto-launches Zsh for WSL interactive sessions.
7. **Optional Git Code Signing:** Automated setup of SSH-based commit signing.

---

## ✅ Compatibility

This installer works especially well on **WSL (Windows Subsystem for Linux)** distros, and has been actively tested on:

* **Ubuntu** (native and WSL)
* **Oracle Linux** (native and WSL)

It should work on most other Debian-based (`apt`) and RHEL-based (`dnf`/`yum`) distros too, since `install.sh` detects the package manager automatically — but these two are the primary, verified targets.

---

## 🚀 One-Command Installation

Run this single command in your terminal to download and run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/aravind666/aravinds-productive-terminal/main/install.sh | bash
```

*Note: If you have cloned the repository locally, you can run it directly:*
```bash
bash install.sh
```

---

## 📦 Installation via apt / dnf (Packages)

Every [release](https://github.com/aravind666/aravinds-productive-terminal/releases) publishes prebuilt `.deb` and `.rpm` packages as release assets. Installing the package automatically configures the shell environment for the user who runs the install command (detected via `sudo`/`SUDO_USER`), so no extra steps are needed afterward.

**Debian / Ubuntu (`apt`):**
```bash
curl -fsSLO https://github.com/aravind666/aravinds-productive-terminal/releases/latest/download/aravinds-productive-terminal_<VERSION>_all.deb
sudo apt install ./aravinds-productive-terminal_<VERSION>_all.deb
```

**Fedora / RHEL / Rocky (`dnf`):**
```bash
curl -fsSLO https://github.com/aravind666/aravinds-productive-terminal/releases/latest/download/aravinds-productive-terminal-<VERSION>-1.noarch.rpm
sudo dnf install ./aravinds-productive-terminal-<VERSION>-1.noarch.rpm
```

Replace `<VERSION>` with the version from the [latest release](https://github.com/aravind666/aravinds-productive-terminal/releases/latest).

> **Note:** The package's postinstall step needs internet access (to fetch Starship, zoxide, fzf, eza, bat, Oh My Zsh, and asdf) and only auto-configures a single invoking user's home directory — it is best suited for personal machines rather than shared multi-user servers.

---

## 🎨 Nerd Font Requirement
To render the Powerline segments (``, ``, ``, ``) and file/folder icons correctly, you **must** configure your terminal emulator to use a **Nerd Font**:
* Recommended: [Fira Code Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases) or [JetBrains Mono Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases).
* Update settings: Terminal Settings -> Profile (e.g. Ubuntu/Oracle) -> Appearance -> Set **Font face** to your Nerd Font.

---

## 🔖 Versioning & Releases

This project uses [release-please](https://github.com/googleapis/release-please) and [Conventional Commits](https://www.conventionalcommits.org/) to automate versioning, changelogs, and GitHub Releases. See [CONTRIBUTING.md](CONTRIBUTING.md) for the commit format required for pull requests.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## 📄 License

This project is licensed under the [MIT License](LICENSE).
