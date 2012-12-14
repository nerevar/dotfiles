#!/usr/bin/env bash
cd
if [ ! -d dotfiles ]; then
	git clone https://github.com/vtambourine/dotfiles.git
fi
cd dotfiles
set -- -f; source bootstrap.sh