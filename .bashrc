# Disable flow control
stty stop undef
stty start undef
stty rprnt undef

HISTSIZE=5000
HISTFILESIZE=10000
HISTCONTROL=ignoredups:erasedups

alias auth='vim ~/data/_keys/.auth.aes'
alias ls='ls --color=auto'
#alias hibernate='hibernate -F /etc/hibernate/ususpend-disk.conf'

# Run disowned
x() { "$@" & disown $! ; }
# Color enabled man
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
			man "$@"
}
# Bash fzf shortcuts
. /etc/profile.d/fzf.bash

## Check for an interactive session
#[ -z "$PS1" ] && return
#function proml
#{
#case $TERM in
#    xterm*|rxvt*)
#        local TITLEBAR='\[\033]0;\w\007\]'
#        ;;
#    *)
#        local TITLEBAR=''
#        ;;
#esac

##_PS1="\[\033[47;1m\] \W \$\[\033[m\] "
#_PS1="${TITLEBAR}\[\033[46;37m\] \W \$\[\033[m\] "
##_PS1="${TITLEBAR}\[\033[47;1m\] \W \$\[\033[m\] "
#PS2='> '
#PS4='+ '
#SLP="\[\033[47;1;34m\] \j\[\033[0m\]"
#PROMPT_COMMAND='RET=$?; INFO=""; if [[ $RET -ne 0 ]]; then INFO="\[\033[47;1;31m\]$RET\[\033[0m\]"; fi; export PS1="${INFO}${_PS1}";'
#}
#proml

# Run twolfson/sexy-bash-prompt
. ~/.bash_prompt

# Minko
export MINKO_HOME=/home/can/work/projects/minko/minko

# Add environment variable COCOS_CONSOLE_ROOT for cocos2d-x
export COCOS_CONSOLE_ROOT=/home/can/work/projects/umbrella/umbrella-man/3rdParty/cocos2d-x/tools/cocos2d-console/bin
export PATH=$COCOS_CONSOLE_ROOT:$PATH

# Add environment variable COCOS_TEMPLATES_ROOT for cocos2d-x
export COCOS_TEMPLATES_ROOT=/home/can/work/projects/umbrella/umbrella-man/3rdParty/cocos2d-x/templates
export PATH=$COCOS_TEMPLATES_ROOT:$PATH

# Add environment variable ANT_ROOT for cocos2d-x
export ANT_ROOT=/usr/bin
export PATH=$ANT_ROOT:$PATH

# Add environment variable NDK_ROOT for cocos2d-x
export ANDROID_NDK_ROOT=/opt/android-ndk
export PATH=$ANDROID_NDK_ROOT:$PATH

# Add environment variable ANDROID_SDK_ROOT for cocos2d-x
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH=$ANDROID_SDK_ROOT:$PATH
export PATH=$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:$PATH

# ruby
export PATH="$(ruby -e 'print Gem.user_dir')/bin:$PATH"

