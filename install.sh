#!/usr/bin/env bash

set -eu

skip="${1:-}"

main() {
  confirm

  install_brew
  install_brew_packages

  setup_git
  setup_ssh
  setup_nvim

  install_gpg
  install_sshb0t

  install_colorschemes

  echo "Setting keyboard repeat rates..."
  defaults write -g InitialKeyRepeat -int 25 # normal minimum is 15 (225 ms)
  defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

  install_tmuxfiles

  echo "workspace setup complete — open a new window to apply all settings! 🌈"
}

clone_if_not_exist() {
  local remote=$1
  local dst_dir="$2"
  echo "Cloning $remote into $dst_dir"
  if [[ ! -d $dst_dir ]]; then
    git clone "$remote" "$dst_dir"
  fi
}

confirm() {
  if [[ -n "${skip}" ]] && [[ "${skip}" == "-f" ]]; then
    return
  fi

  read -r -p "Are you sure? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      return
      ;;

    *)
      echo "Bailing out, you said no"
      exit 187
      ;;
  esac
}

install_brew() {
  set +e
  echo "Install Hombrew..."
  if [[ -z "$(brew -v)" ]]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  set -e
}

install_brew_packages() {
  set +e

  echo "Running the Brewfile..."
  brew update
  brew tap Homebrew/bundle
  ln -sf "$(pwd)/Brewfile" "${HOME}/.Brewfile"
  brew bundle --global
  brew bundle cleanup

  set -e
}

setup_git() {

  echo "Copy the zshrc file into .zshrc"
  ln -sf "$(pwd)/zshrc" "${HOME}/.zshrc"

  echo "Copy the gitconfig file into ~/.gitconfig..."
  cp -rf "$(pwd)/gitconfig" "${HOME}/.gitconfig"

  echo "Copy the inputrc file into ~/.inputrc..."
  ln -sf "$(pwd)/inputrc" "${HOME}/.inputrc"
}

setup_nvim() {

  echo "Copy the nvim folder into ~/.config/nvim ..."
  ln -sf "$(pwd)/nvim" "${HOME}/.config/nvim"

  clone_if_not_exist https://github.com/wbthomason/packer.nvim "${HOME}/.local/share/nvim/site/pack/packer/start/packer.nvim"
  clone_if_not_exist https://github.com/github/copilot.vim.git "${HOME}/.config/nvim/pack/github/start/copilot.vim"
}

setup_ssh() {
  echo "Setting up SSH config"
  if [[ ! -d ${HOME}/.ssh ]]; then
    mkdir "${HOME}/.ssh"
    chmod 0700 "${HOME}/.ssh"
  fi
}

install_gpg() {
  echo "Installing gpg..."
  if ! [[ -d "${HOME}/.gnupg" ]]; then
    mkdir "${HOME}/.gnupg"
    chmod 0700 "${HOME}/.gnupg"

  cat << EOF > "${HOME}/.gnupg/gpg-agent.conf"
default-cache-ttl 3600
pinentry-program /usr/local/bin/pinentry-mac
enable-ssh-support
EOF

    gpg-connect-agent reloadagent /bye > /dev/null
  fi
}


install_sshb0t() {
  go install github.com/genuinetools/sshb0t@latest

  echo "sshb0t installed!"

  sshb0t --once \
    --user dolfolife
}

install_colorschemes() {
  echo "Cloning colorschemes..."
  clone_if_not_exist https://github.com/chriskempson/base16-shell.git "${HOME}/.config/base16-shell"
}

install_tmuxfiles() {
  set +e
    tmux list-sessions # this exits 1 if there are no sessions

    if [ $? -eq 0 ]; then
      echo "If you'd like to update your tmux files, please kill all of your tmux sessions and run this script again."
      exit 1
    else
      mkdir -p ~/.tmux/plugins/

      if [[ -f ~/.tmux.conf && "$(readlink -f ~/.tmux.conf)" != "$(pwd)/tmux.conf" ]]; then
        echo -n "Existing ~/.tmux.conf found. Overwrite? (y/N) "
        read -r response
        if [[ "${response}" == "y" ]]; then
          rm -f ~/.tmux.conf
        else
          echo "${RED}Installation aborted.${END_COLOR}"
          exit 1
        fi
      fi

      if [[ ! -L ~/.tmux.conf ]]; then
        ln -s "$(pwd)/tmux.conf" ~/.tmux.conf
      fi

      if [[ ! -d ~/.tmux/plugins/tpm ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
     fi

      ~/.tmux/plugins/tpm/bin/install_plugins
      ~/.tmux/plugins/tpm/bin/update_plugins all
      ~/.tmux/plugins/tpm/bin/clean_plugins

    fi
  set -e
}

main "$@"
