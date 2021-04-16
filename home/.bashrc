# .bashrc, run by every non-login bash
# aliases and transient shell options that are not inherited by child processes

# echo "$(date) .bashrc" >> .profile.log

## Readline and key binds ####################################################

if [[ ${SHELLOPTS} =~ (vi|emacs) ]]; then

    # If there are multiple matches for completion,
    # Tab should cycle through them
    bind 'TAB':menu-complete

    # Display a list of the matching files
    bind "set show-all-if-ambiguous on"

    # Perform partial completion on the first Tab press,
    # only start cycling full results on the second Tab press
    bind "set menu-complete-display-prefix on"

fi

## Env vars related to interacive prompt #####################################
# (other env vars are in .profile)

# PS1
case $- in

# interactive shell
*i*)
  pre='\[\e['
  post='m\]'

  green="${pre}32${post}"
  magenta="${pre}95${post}"
  dim_cyan="${pre}96${post}"
  bright_yellow_inverse="${pre}93;1;7${post}"
  reset="${pre}00${post}"

  pwd="$dim_cyan\w$reset"
  prompt="$bright_yellow_inverse\$$reset"
  user="${USER}"
  if [ "$user" = "jhartley" ]; then
    user="${green}${user}${reset}"
  else
    user="${magenta}${user}${reset}"
  fi
  host="${HOSTNAME%%.*}"
  if [ "$host" = "t460" ]; then
    host="${green}t460${reset}"
  elif [ "$host" = "asus" ]; then
    host="${green}asus${reset}"
  else
    host="${magenta}${host}${reset}"
  fi

  . ~/.ps1_vcs

  export PS1="${user}@${host} $pwd\$(${dvcs_function})\n$prompt "

  unset pre post green magenta dim_cyan bright_yellow_inverse reset pwd prompt

  # Whenever displaying the prompt, append history to disk
  PROMPT_COMMAND='history -a'
  # To have all terminals sync their history after every command
  # PROMPT_COMMAND='history -a; history -n'

  # if exit value isn't zero, display it with red background, and a bell
  PROMPT_COMMAND='EXITVAL=$?; '$PROMPT_COMMAND
  GET_EXITVAL='$(if [[ $EXITVAL != 0 ]]; then echo -ne "\[\e[37;41;01m\] $EXITVAL \[\e[0m\]\07 "; fi)'
  export PS1="$GET_EXITVAL$PS1"

  # turn off flow control, mapped to ctrl-s, so that we regain use of that key
  # for searching command line history forwards (opposite of ctrl-r)
  stty -ixon

;;

# non-interactive shell
*)
;;

esac

# Set dircols if terminal can handle it
if [ "$TERM" != "dumb" ]; then
    eval `dircolors -b $HOME/.dircolors`
fi


## options to coreutils #####################################################

# Requires latest gnu coreutils, maybe don't work with Mac's old built-in ones
alias cp='cp -i'
alias df='df -h'
alias du='du -h'
alias histread='history -c; history -r'
alias less='less -R' # display raw control characters for colors only
alias ll='ls -lAGh'
alias ls='LC_COLLATE="C" ls $LS_OPTIONS'
alias mv='mv -i'
alias rm='rm -i'
alias ssh='TERM=xterm-color ssh'
alias timee='/usr/bin/time -f %E'
alias cd-='cd -'
alias cd..='cd ..'

## Functions ##############################################

function nh {
    nohup "$@" 1>/dev/null 2>&1 &
}

# Allows use of 'watch' with aliases or functions
function watcha {
    watch -ctn1 "bash -i -c \"$@\""
}

function colout_traceroute () {
    colout '(^ ?\d+)|(\([\d\.]+\))|([\d\.]+ ms)|(!\S+)' white,cyan,yellow,magenta bold,normal,normal,reverse
}

function pytree {
    tree -AC -I '*.pyc|__pycache__' "$@"
}

function etime {
    /usr/bin/time -f"%E" "$@"
}

# ctags files

# Use 'pytags $(pydirs) .' to tag with all stdlib and venv symbols
function pydirs {
    python -c "import os, sys; print(' '.join(os.path.relpath(d) for d in sys.path if d))"
}

# git stuff
# See also ~/bin for commands I use non-interactively, eg. "watch gd"

function gs {
    git status -s "$@"
}

function gst {
    git status "$@"
}

function ga {
    git add "$@"
}

function gci {
    git commit --verbose "$@"
}

function gco {
    git checkout "$@"
}

function gdst {
    git diff --stat=160,120
}

function gr {
    git remote -v | sed 's/git+ssh:\/\/tartley@git\.launchpad\.net\//lp:/g' | colout '(^\S+)\s+(lp:)?\S+\s+\((fetch)?|(push)?\)$' cyan,yellow,blue,green normal
}

# git log, pretty one line per commit, with graph
function glog {
    git log --graph --format=format:"%x09%C(yellow)%h%C(reset) %C(green)%ai%x08%x08%x08%x08%x08%x08%C(reset) %C(white)%an%C(reset)%C(auto)%d%C(reset)%n%x09%C(dim white)%s%C(reset)" --abbrev-commit "$@"
    echo
}

# git log, pretty one line per commit, with graph
function gloga {
    glog --all "$@"
}

# git log, further abbreviated one line per commit, with graph
function gl {
    git log --graph --format=format:"%C(yellow)%h%C(reset)%C(auto)%d%C(reset)%C(white) %s%C(reset)" --abbrev-commit "$@"
    echo
}

# git log, further abbreviated one line per commit, with graph
function gla {
    gl --all "$@"
}

# git log branch - show the commits behind a given merge
function glb {
    git log --graph $(git merge-base --octopus $(git log -1 --pretty=format:%P $1)).. --boundary
}

function gaa {
    git add --all
}

# push, with tags
function gp {
    git push "$@" --tags
}

# pull and push, with tags
# TODO: Should this use pull? Which might or might not produce a merge commit?
# We probably want to gff instead. And shoulnd't gff do a fetch first?
# Hmmm more thinking reqd.
function gpp {
    git pull && git fetch --tags && git push --follow-tags
}

# output current branch name
function gbranch {
    git branch "$@" | grep '^*'| cut -d' ' -f2
}

function gb {
    git branch -vv --color=always "$@"
}

# output tags at the current commit
function gtags {
    git log -n1 --pretty=format:%C\(auto\)%d | sed 's/, /\n/g' | grep tag | sed 's/tag: \|)//g'
}

# git fast forward
# Arg1: branch to merge into current (like regular merge)
# Will abort if cannot ff (eg. current has commits not in Arg1.)
function gff {
    git merge --ff-only -q "$@"
}

# git merge
# Arg1: branch to merge into current (like regular merge)
# With no fast forward, ie. always create a merge commit.
function gm {
    git merge --no-ff -q "$@"
}

# git fetch master
# No args
# Fetch latest master from origin
function gfm {
    # Fetch lastest master from origin, and ff-merge into local master.
    # Doesn't work if master is current branch. Use "gff origin/master" instead.
    git fetch origin master:master
}

# git fetch master & rebase
# No args
function gfmr {
    # Fetch latest master from origin
    gfm
    # and rebase current branch onto it
    git rebase master
}

# git fetch master & merge
# No args
function gfmm {
    # Fetch latest master from origin
    gfm
    # and merge it into our current branch
    git merge -q master
}

. ~/.git-completion


## bzr ####

alias bs='bzr status && bzr show-pipeline'
alias bt='bzr log -r-1' # tip

function bl {
    bzr log "$@" | less
}

function blp {
    bzr log -v -p "$@" | colordiff | colout -- '^.{7}(-{5,})' cyan reverse | less
}

function bup {
    bzr unshelve --preview "$@" | colordiff
}

##

# show man pages rendered using postscript
function psman () {
    SLUG=$(echo $@ | tr ' ' '-')
    FNAME="/tmp/man-$SLUG.pdf"
    set -o pipefail
    man -t "$@" | ps2pdf - "$FNAME" && \
        nohup evince "$FNAME" >/dev/null 2>/dev/null
    set +o pipefail
}

function pywait () {
    find -name 'env' -prune -o -name '*.py' -print | entr "$@"
}

## aliases #################################################################

alias whence='type -a' # where, of a sort
alias dateiso="date +%Y%m%d-%H%M%S"
alias open='xdg-open 2>/dev/null'

# if colordiff is installed, use it
if type colordiff &>/dev/null ; then
    alias diff=colordiff
fi

## Terminal frippery. ######################################################

# Change terminal window / tab name
function termname {
  printf "\e]2;$1\a"
}

# call given command every second until a key is pressed
function repeat_until_key () {
    command="$@"
    while true; do
        $command
        read -s -n1 -t1 && break
    done
}

# Flash whole terminal inverse video until key press
function flashes () {
    repeat_until_key flash
}

## Shell Options (See man bash) #############################################

# Don't wait for job termination notification
set -o notify

# Don't use ^D to exit
set -o ignoreeof

# Make bash append rather than overwrite the history on disk
shopt -s histappend

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# save multi-line commands as a single line in the history.
shopt -s cmdhist
# and use newlines to separate rather than semi-colons
shopt -s lithist

# don't autocomplete if command-line is empty
shopt -s no_empty_cmd_completion


## Tool setup ###############################################################

## FZF
# Neovim plugin config:
# Solarized colors
export FZF_DEFAULT_OPTS='
  --color bg+:#073642,bg:#002b36,spinner:#719e07,hl:#618e04
  --color fg:#839496,header:#586e75,info:#000000,pointer:#719e07
  --color marker:#719e07,fg+:#839496,prompt:#719e07,hl+:#719e17
'
# Bash command line:
[ -f ~/.fzf.bash ] && source ~/.fzf.bash || :

# Go version master
if [[ -s "/home/jhartley/.gvm/scripts/gvm" ]] ; then
    source "/home/jhartley/.gvm/scripts/gvm"
fi

## LXD ##################################################### 

# lxc list long
function lll {
    lxc list -cns4 \
        | grep '\w' \
        | tr -d '|' \
        | colout '(^\s+NAME\s.+)|(RUNNING)|(STOPPED)' white,green,red bold,normal
}

# lxc list short
function lls {
    lxc list -cn --format=csv
}

# Define lxc container name aliases.
declare -A laliases
# siab
laliases[delta]=siab-xenial
laliases[devicegw]=siab-xenial
laliases[find]=siab-bionic
laliases[ident]=siab-bionic
laliases[publishergw]=siab-xenial
laliases[revs]=siab-xenial
laliases[schemas]=siab-xenial
laliases[snapdevicegw]=siab-xenial
laliases[snapfind]=siab-bionic
laliases[snapident]=siab-bionic
laliases[snaprevs]=siab-xenial
# storage
laliases[storage]=snapstorage-xenial
laliases[snapstorage]=snapstorage-xenial
# charm-migration
laliases[charm-migration]=charm-migration-focal

# Given a project name or container alias,
# return the actual hosting container name.
function lalias {
    alias="$1"
    # If an alias was given, return the corresponding container name.
    if [ -n "$alias" ]; then
        # If the given alias is recognized, return the corresponding container
        container="${laliases[$alias]}"
        if [ -n "$container" ]; then
            echo "$container"
            return 0
        else
            # Look for the alias in container names.
            for container in $(lls); do
                if [ "$container" = "$alias" ]; then
                    echo "$container"
                    return 0
                fi
            done
            # Alias not recognized.
            echo "lalias: Alias '$alias' not recognized." >&2
            return 2
        fi
    else
        # No alias was given. Display all aliases.
        containers=$(echo ${laliases[@]} | tr ' ' '\n' | sort -u)
        for container in $containers; do
            echo "$container"
            for alias in ${!laliases[@]}; do
                if [ ${laliases[$alias]} = $container ]; then
                    echo -e "\t$alias"
                fi
            done
        done
    fi
}

function lssh {
    if [ "$#" -ne 1 ] ; then
        echo "Usage: lssh <projectname>"
        return
    fi
    alias="$1"
    container=$(lalias $alias)

    tname="$container"
    destdir="$PWD"
    if [ -d "$HOME/src/$alias" ]; then
        tname="$alias on $container"
        if [ "$PWD" = "$HOME" ]; then
            destdir="$HOME/src/$alias"
        fi
    fi
    termname "$tname"

    host="$container.lxd"
    # # Old old method, scraping IP from output of 'lxc list'
    # host=$(lxc list $container -c 4 | grep eth0 | cut -d' ' -f2)

    # ssh to container.
    # Requires containers to have IPv4 address,
    # and name resolution to be working.
    # -A: Forward ssh-agent. So we can, for example,
    #     hit github using passphrases cached by ssh-agent.
    # -t: Force pseudo-terminal allocation. (I forget why.)
    # See ~/docs/config/lxd.dns.md for DNS resolution of .lxd domain
    ssh -A -t "${host}" -- "cd $destdir && exec $SHELL -l"

    # # Old method of connecting, for when container network is broken.
    # # exec a login session in the container, as jhartley.
    # # The extra nested bash invocation is to cd to the given directory.
    # # Is there an easier way to do that?
    # lxc exec "$container" -- \
    #     sudo --login --user $USER -- \
    #         bash -c "cd $PWD && exec $SHELL -l"

    termname "Terminal"
}

# autocomplete lxc container names
# The 2> is to silence errors when logging into a xenial container, on
# on which lxd doesn't support csv format. But I don't currently use
# subcontainers, so I don't care if this doesn't work there,
# so we can just ignore the error.
# TODO: convert the -W into a -F to get an up-to-date list on demand
# See -F explaination at
# https://unix.stackexchange.com/questions/250262/how-to-use-bashs-complete-or-compgen-c-command-option/250484#250484
complete -W "$(lls 2>/dev/null) $(lalias)" lssh lxc


## On exit ##################################################################

# Remove duplicated lines from the history
# Leave the *last* occurence of duplicates.
# Does this by reversing the file (tac) before deduping,
# then reversing it again.
# Assumes it doesn't have timestamp lines in it.

function dedupe_history () {
    tac < ~/.bash_history | awk '!a[$0]++' | tac >/tmp/deduped \
        && mv -f /tmp/deduped ~/.bash_history
}
trap dedupe_history EXIT


## Source all ~/.bashrc.* files. ############################################

for fname in $(ls ~/.bashrc.*); do
    # echo "calling $fname"
    . $fname
done

