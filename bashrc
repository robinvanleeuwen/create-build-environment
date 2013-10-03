########################################################################
## # INFO: this file is puppeted (WdG 2013-01-23)                     ##
########################################################################

# ~/.bashrc: executed by bash(1) for non-login shells.
# Get OUT! when no tty: 
[ -z "$PS1" ] && return

if [ -e '/etc/bash_completion' ]; then
	. /etc/bash_completion
fi

__byte_git_ps1()
{
        present=$(type -t __git_ps1)
        if [ -z "$present" ]; then
                return;
        fi

	pwd=$(pwd)
	if [ "${pwd:0:12}" = "/home/users/" ]; then
		return;
	else
		echo "$(__git_ps1)";
	fi
}

########################################################################
## Change the window title of X terminals (WdG 2013-01-23)            ##
########################################################################

case $TERM in
    xterm*|rxvt|Eterm|eterm)
        PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
        ;;  
    screen)
        PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
        ;;  
esac

export IPMI_PASSWORD=$(cat /etc/ipmipw 2>/dev/null)

########################################################################
## Various (WdG 2013-01-23)                                           ##
########################################################################

umask 022
shopt -s checkwinsize

########################################################################
## Usefull aliases (WdG 2013-01-23)                                   ##
########################################################################
customaliasesfile="/root/.custom_aliases"
if [ -e "$customaliasesfile" ]; then
	source $customaliasesfile
fi

custompathfile="/root/.custom_path"
if [ -e "$custompathfile" ]; then
	source $custompathfile
fi

export LS_OPTIONS='--color=auto'
eval "`dircolors`"

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lh'
alias l='ls $LS_OPTIONS -lhA'
alias t='tail -f'
alias c='clear'

alias status='cat /root/.serverstatus'
alias cputop='ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10'


# handy navigating: 
alias cd..='cd ..'
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias cd......='cd ../../../../..'

alias ap='apt-cache policy'
alias ai='apt-get install'
alias as='apt-cache search'

########################################################################
## History stuff (WdG 2013-01-23)                                     ##
########################################################################

#Make sure the `history` command shows the timestamp
export HISTTIMEFORMAT="%F %T "

#We want a bigger history scrollback
export HISTFILESIZE=10000
export HISTSIZE=10000

#Save history properly even with multiple open sessions.
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
shopt -s histappend

########################################################################
## Force GIT creds (WdG 2013-01-23)                                   ##
########################################################################

#~ SSH_KEY_NAME=$(ssh-add -L | cut -d' ' -f 3 | cut -d'@' -f 1)
SSH_KEY_NAME=$(
    for key in `ssh-add -L | awk {' print $2 '}`;
    do 
        grep $key ~/.ssh/authorized_keys;
    done | head -1 | cut -d' ' -f3 | cut -d@ -f1
)

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=verbose

if [[ $SSH_KEY_NAME ]];
then
	export PS1='\[\033[01;31m\]\u/$SSH_KEY_NAME@$BYTE_HOSTNAME\[\033[01;34m\]$(__byte_git_ps1 " (%s)") \w # \[\033[00m\]'

        if [[ -x /usr/bin/git && `git config user.email` == 'tech@byte.nl' ]];
        then
               export GIT_COMMITTER_NAME=${SSH_KEY_NAME^}
               export GIT_AUTHOR_NAME=${SSH_KEY_NAME^}

               export GIT_COMMITTER_EMAIL=$SSH_KEY_NAME@byte.nl
               export GIT_AUTHOR_EMAIL=$SSH_KEY_NAME@byte.nl
        fi
else
	export PS1='\[\033[01;31m\]\u@$BYTE_HOSTNAME\[\033[01;34m\]$(__byte_git_ps1 " (%s)") \w # \[\033[00m\]'
fi

if [ -f /root/mijn-apt-get-is-brak ]; then
	apt-get update
	sed -i 's/#//g' /etc/apt/sources.list 
	apt-get update
	rm /root/mijn-apt-get-is-brak
fi

function mountshizzle() {
	mount sysfs /sys -t sysfs
	mount prox /proc -t proc
	mount udev /dev -t devtmpfs
	mount tmpfs /run -t tmpfs
	mount devpts /dev/pts -t devpts

}

mountshizzle

function umountshizzle() { 

	echo "Unmounting device stuff"
	umount /tmp
	umount /sys
	umount /dev/pts
	umount /run
	umount /dev
	umount /proc
	echo "Done, goodbye!"

}

trap umountshizzle EXIT

export LC_ALL="C"

