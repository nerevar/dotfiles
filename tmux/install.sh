printf "Installing tmux..."
{
    rm -rf ${HOME}/dotfiles/tmux/tpm
    git clone https://github.com/tmux-plugins/tpm ${HOME}/dotfiles/tmux/plugins/tpm
    ${HOME}/.tmux/plugins/tpm/bin/install_plugins
} &> /dev/null
printf " DONE.\n"
