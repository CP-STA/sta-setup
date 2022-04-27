# Introduction
The machines in the labs can be quite difficult to work with sometimes especially with broken gcc complier, no package manager, and chsh not working. This script tries to side step the problem with homebrew, which can install packages in user space. It also comes with some (opinionated) niceties like oh-my-zsh, syntax highlighting and auto completion, which are quite useful. 

# Installation
```bash
/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/STAOJ/sta-setup/master/setup.sh)"
```

And then restart your shell for it to take effect.

# What it looks like after installation
![Screenshot](./screenshot.png)

# Troubleshooting
1. Build failure with `brew install`.

    The make complier on the lab machines is a bit broken. We haven't found a way to fix it yet, but you can workaround many build failures with `brew install --force-bottle` to use a "bottle" (pre-complied binary). Homebrew defaults to building from source because it is not installed in `/home/linuxbrew/.linuxbrew` (for which you don't have write permission). 

2. Problem with PATH.

    Try to add the PATH in `~/.profile`, which will get loaded.

# Customization
The theme used is powerlevel10k, applied on oh-my-zsh. the font for p10k is chosen for the compatibility. If you want to customize the prompt look, run `p10k configure`. 

You can also read more about the two packages to learn more about what they can do. 