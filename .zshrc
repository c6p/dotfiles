source /usr/share/zsh/scripts/antigen/antigen.zsh
antigen use oh-my-zsh

antigen bundles <<EOBUNDLES
  command-not-found
  zsh-users/zsh-syntax-highlighting
  kennethreitz/autoenv
EOBUNDLES

antigen theme agnoster

