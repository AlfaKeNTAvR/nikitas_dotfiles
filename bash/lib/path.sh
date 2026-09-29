# Put ~/.local/bin on PATH, where install.sh puts tools that have no apt package
# (lazygit, serie). Ubuntu's ~/.profile only adds it when the directory existed
# at login, so a first install would otherwise need a logout to take effect.
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
