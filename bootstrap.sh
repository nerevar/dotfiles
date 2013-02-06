#!/usr/bin/env bash

DOTFILES_DIRECTORY="${HOME}/dotfiles"
DOTFILES_GIT_REMOTE="https://github.com/vtambourine/dotfiles"
DOTFILES_GIT_BRANCH="master"
DOTFILES_BOOTSTRAP="https://raw.github.com/vtambourine/dotfiles/${DOTFILES_GIT_BRANCH}/`basename $0`"
DOTFILES_TARBALL_PATH="${DOTFILES_GIT_REMOTE}/tarball/${DOTFILES_GIT_BRANCH}"

# Processing options
while : ; do
    case "$1" in
        -e | --with-extra) # Also download and update side configurations
            with-extra=1
            shift;;
        -k | --with-keys) # Also copy ssh keys
            with-keys=1
            shift;;
        -p | --with-packages) # Install and update packages
            with-packages=1
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
        ssh $1 -- "curl -kfsSL $DOTFILES_BOOTSTRAP \$1 | bash -s -- --force"
        shift
    done
    exit 0
fi

# Download and extract the repository to the home directory if the directory is missing
if [ ! -d ${DOTFILES_DIRECTORY} ]; then
    printf "Downloading dotfiles...\n"
    mkdir -p ${DOTFILES_DIRECTORY}
    # Get the tarball
    curl -fsSLo ${HOME}/dotfiles.tar.gz ${DOTFILES_TARBALL_PATH}
    # Extract to the dotfiles directory
    tar -zxf ${HOME}/dotfiles.tar.gz --strip-components 1 -C ${DOTFILES_DIRECTORY}
    # Remove the tarball
    rm -rf ${HOME}/dotfiles.tar.gz
fi

cd ${DOTFILES_DIRECTORY}

source ./lib/utils.sh

# Initialize the git repository if it's missing
if ! is_git_repo && `type_exists 'git'`; then
    e_header "Initializing git repository..."
    git init
    git remote add origin ${DOTFILES_GIT_REMOTE}
    git fetch origin master
    # Reset the index and working tree to the fetched HEAD
    # (submodules are cloned in the subsequent sync step)
    git reset --hard FETCH_HEAD
    # Remove any untracked files
    git clean -fd
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
    link "bash/bashrc"        ".bashrc"
    link "bash/bash_profile"  ".bash_profile"
    link "bash/bash_prompt"   ".bash_prompt"
    link "bash/inputrc"       ".inputrc"
    link "git/gitconfig"      ".gitconfig"
    link "git/gitattributes"  ".gitattributes"
    link "git/gitignore"      ".gitignore"
    link "vim"                ".vim"
    link "vim/vimrc"          ".vimrc"
    link "ssh/config"         ".ssh/config"

    printf "Dotfiles update complete!\n"
}

if [ ! $force ]; then
    # Verify that you want to proceed before potentially overwriting files
    printf "\n"
    printf "Warning: This step may overwrite your existing dotfiles. "
    read -p "Continue? (y/n) " -n 1
    printf "\n"
fi

if [[ $force || $REPLY =~ ^[Yy]$ ]]; then
    mirrorfiles
    source ${HOME}/.bash_profile
else
    printf "Aborting...\n"
    exit 1
fi
