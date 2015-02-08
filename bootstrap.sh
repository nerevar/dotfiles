#!/usr/bin/env bash

DOTFILES_DIRECTORY="${HOME}/dotfiles"
DOTFILES_GIT_REPO="https://github.com/nerevar/dotfiles"
DOTFILES_GIT_REMOTE="git@github.com:nerevar/dotfiles.git"
DOTFILES_GIT_BRANCH="master"
DOTFILES_BOOTSTRAP="${DOTFILES_GIT_REPO}/raw/${DOTFILES_GIT_BRANCH}/`basename $0`"
DOTFILES_TARBALL_PATH="${DOTFILES_GIT_REPO}/archive/${DOTFILES_GIT_BRANCH}.tar.gz"

# Processing options
while : ; do
    case "$1" in
        -e | --with-extra) # Also download and update side configurations
            with_extra=1
            shift;;
        -k | --with-keys) # Also copy ssh keys
            with_keys=1
            shift;;
        -p | --with-packages) # Install and update packages
            with_packages=1
            shift;;
        -s | --silent) # Silent install
            export silent=1
            shift;;
        -f | --force) # Overwrite existing files
            force=1
            shift;;
        -* | --*)
            printf "Warning: Unknown option: $1" >&2
            exit 1;;
        *)
            break;;
    esac
done

# Deploy dotfiles on the remote host if one is provided
if [ $# -gt 0 ]; then

    while [ $1 ]; do
        ssh -q $1 "curl -kfsSL $DOTFILES_BOOTSTRAP | bash -s -- --force --silent" 2>/dev/null
        if [[ with_keys ]]; then
            KEYCODE=`cat ${HOME}/.ssh/id_rsa.pub`
            ssh -q $1 "mkdir ~/.ssh 2>/dev/null; chmod 700 ~/.ssh; echo "$KEYCODE" >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys" 2>/dev/null
        fi
        shift
    done
    exit 0

else

    # Download and extract the repository to the home directory if the directory is missing
    if [ ! -d ${DOTFILES_DIRECTORY} ]; then
        printf "Downloading dotfiles...\n"
        mkdir -p ${DOTFILES_DIRECTORY}
        # Get the tarball
        curl -kfsSLo ${HOME}/dotfiles.tar.gz ${DOTFILES_TARBALL_PATH}
        # Extract to the dotfiles directory
        tar -zxf ${HOME}/dotfiles.tar.gz --strip-components 1 -C ${DOTFILES_DIRECTORY}
        # Remove the tarball
        rm -rf ${HOME}/dotfiles.tar.gz
    fi

    cd ${DOTFILES_DIRECTORY}

    source ./lib/utils.sh

    # Initialize the git repository if it's missing
    if type_exists 'git'; then
        if is_git_repo; then
            echo "Updating git repository..."
            git pull --rebase origin ${DOTFILES_GIT_BRANCH}
        else
            echo "Initializing git repository..."
            git init
            git remote add origin ${DOTFILES_GIT_REMOTE}
            git fetch origin ${DOTFILES_GIT_BRANCH}
            # Reset the index and working tree to the fetched HEAD
            # (submodules are cloned in the subsequent sync step)
            git reset --hard FETCH_HEAD
            # Remove any untracked files
            git clean -fd
        fi
    fi

    mirrorfiles() {
        # Force remove the vim directory if it's already there.
        if [ -e "${HOME}/.vim" ]; then
            rm -rf "${HOME}/.vim"
        fi

        # Create ssh directory if necessary.
        if [ ! -e "${HOME}/.ssh" ]; then
            mkdir -m 0700 "${HOME}/.ssh"
        fi

        # Create the necessary symbolic links between the `dotfiles` and `HOME`
        # directory. The `bash_profile` sources other files directly from the
        # `.dotfiles` repository.
        link "bash/bash_profile"  ".bash_profile"
        link "git/gitconfig"      ".gitconfig"
        link "git/gitignore"      ".gitignore"
        link "tmux/tmux.conf"     ".tmux.conf"
        link "vim"                ".vim"
        link "vim/vimrc"          ".vimrc"
        link "tilde/ackrc"        ".ackrc"

        printf "Dotfiles update complete!\n"
    }

    mirrorfiles
    sh ${HOME}/.vim/install.sh
    source ${HOME}/.bash_profile

fi
