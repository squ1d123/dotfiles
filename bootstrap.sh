#!/bin/sh

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# --------------------------------------------------
# LIBRARY FUNCTIONS

git_update() {
  # Either clones a directory if it doesn't exist at the given location
  # or pulls it if it does exist.
  # $1 = repo URL
  # $2 = directory

  echo "git_update $1 $2..."
  if [ -d "$2" ]; then
    (
        cd "$2"
        # Pull down the latest master and replay our changes on top.
        git pull --rebase --stat origin master
    )
  else
    git clone $1 $2;
  fi
}

# --------------------------------------------------
# ACTIONS

usage() {
  echo "Usage:"
  echo "  all           Do everything!"
  echo "  install       Install commonly used software"
  echo "  configure     Configure installed software"
  echo "  link          Link configs with stow"
  echo "  unlink        Unlink configs with stow"
}

install_pkg() {
  OS=$(uname)

  # Universal list of software for all operating systems.
  # This list can be added to by other OSes. Useful if there are differences between package names.
  SOFTWARE="stow git tig tmux cmake zsh ncdu htop tree dict jq"

  case $OS in
    "Linux")
      # https://writequit.org/org/#6017d330-9337-4d97-82f2-2e605b7a262a
      # returns a string like "Fedora" or "Ubuntu" or "Debian"
      # DISTRO=`lsb_release -i | cut -d: -f 2 | tr -d '[:space:]'`
      # DISTRO=`lsb_release -i | cut -f 2`
      DIST=$(cat /etc/*release | grep -E "^ID=.*" | cut -d= -f 2 | sed "s/\"//g" )

      case $DIST in
          "rhel")
              PKGMAN="yum install"
              SOFTWARE="$SOFTWARE the_silver_searcher vim neovim python36-neovim"
              ;;
          "ubuntu")
              PKGMAN="apt-get install"
              SOFTWARE="$SOFTWARE build-essential silversearcher-ag ack-grep dictd dict-gcide vim"
              ;;
          *)
              echo "Unknown DIST: $DIST"
              exit
      esac
      ;;
    "Darwin")
      ;;
    "FreeBSD")
      PKGMAN="pkg install"
      SOFTWARE="$SOFTWARE the_silver_searcher ack neovim"
      ;;
    *)
      echo "Unknown OS: $OS"
      exit
      ;;
  esac

  echo "Detected OS: $OS"
  echo "sudo $PKGMAN $SOFTWARE"
  sudo $PKGMAN $SOFTWARE
}

install_git() {
  git_update https://github.com/sickill/stderred.git    ~/.stderred
  git_update https://github.com/zsh-users/antigen.git   ~/.antigen
  # git_update https://github.com/syl20bnr/spacemacs      ~/.emacs.d
}

configure() {
  git config --global core.excludesfile ~/.gitignore_global

  # set zsh as the default shell
  sudo chsh -s /bin/zsh $USER

  # TODO Install stderred.
}

link() {
  stow -d $SCRIPTPATH -vt ~ conf
}

unlink() {
  stow -d $SCRIPTPATH -vDt ~ conf
}

# -----------------------------------------------
# MAIN

if [ "$#" -ne 1 ]; then
  usage
  exit
fi

case $1 in
  "all")
    install_pkg
    install_git
    configure
    link
    ;;
  "install")
    install_pkg
    install_git
    ;;
  "link")
    link
    ;;
  "unlink")
    unlink
    ;;
  "configure")
    configure
    ;;
  *)
    echo "Invalid command."
    usage
    ;;
esac

