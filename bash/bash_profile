for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
[ -r "$file" ] && source "$file"
done
unset file

export LC_ALL="ru_RU.UTF-8"
export LANG="ru_RU"

export PATH=./node_modules/.bin:/usr/local/share/npm/bin:$PATH
export NODE_PATH="/usr/local/lib/node_modules"

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
# Make some commands not show up in history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"