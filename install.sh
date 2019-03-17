#!/usr/bin/env bash

set -eu

skip="${1:-}"

main() {
  confirm

#  install_brew
#  install_brew_packages

  setup_git
  setup_ssh

  install_gpg
  install_ruby
  install_sshb0t
  install_nvimfiles
  install_go_deps

  install_colorschemes

  echo "Setting keyboard repeat rates..."
  defaults write -g InitialKeyRepeat -int 25 # normal minimum is 15 (225 ms)
  defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

  install_tmuxfiles

  echo "Workstation setup complete — open a new window to apply all settings! 🌈"
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
  echo "Symlink the git-authors file to .git-authors..."
  ln -sf "$(pwd)/git-authors" "${HOME}/.git-authors"

  echo "Copy the bash_profile file into .bash_profile"
  ln -sf "$(pwd)/bash_profile" "${HOME}/.bash_profile"

  echo "Copy the gitconfig file into ~/.gitconfig..."
  cp -rf "$(pwd)/gitconfig" "${HOME}/.gitconfig"

  echo "Copy the inputrc file into ~/.inputrc..."
  ln -sf "$(pwd)/inputrc" "${HOME}/.inputrc"

  echo "Link global .gitignore"
  ln -sf "$(pwd)/global-gitignore" "${HOME}/.global-gitignore"

  echo "link global .git-prompt-colors.sh"
  ln -sf "$(pwd)/git-prompt-colors.sh" "${HOME}/.git-prompt-colors.sh"
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

install_ruby() {
  ruby_version=2.4.2
  echo "Installing ruby $ruby_version..."
  rbenv install -s $ruby_version
  rbenv global $ruby_version
  rm -f ~/.ruby-version
  eval "$(rbenv init -)"
  echo "Symlink the gemrc file to .gemrc..."
  ln -sf "$(pwd)/gemrc" "${HOME}/.gemrc"

  echo "Install the bundler gem..."
  gem install bundler

  echo "Creating workspace..."
  workspace=${HOME}/workspace
  mkdir -p "$workspace"

  echo "Creating go/src..."
  go_src=${HOME}/go/src
  if [ ! -e "${go_src}" ]; then
    mkdir -pv "${HOME}/go/src"
  fi

  if [ -L "${go_src}" ]; then
    echo "${go_src} exists, but is a symbolic link"
  fi
}

install_sshb0t() {
  latest_tag=$(curl -s https://api.github.com/repos/genuinetools/sshb0t/releases/latest | jq -r .tag_name)

  # If the curl to the github api fails, use latest known version
  if [[ "$latest_tag" == "null" ]]; then
    latest_tag="v0.3.5"
  fi

  # Export the sha256sum for verification.
  sshb0t_sha256=$(curl -sL "https://github.com/genuinetools/sshb0t/releases/download/${latest_tag}/sshb0t-darwin-amd64.sha256" | cut -d' ' -f1)

  # Download and check the sha256sum.
  curl -fSL "https://github.com/genuinetools/sshb0t/releases/download/${latest_tag}/sshb0t-darwin-amd64" -o "/usr/local/bin/sshb0t" \
    && echo "${sshb0t_sha256}  /usr/local/bin/sshb0t" | shasum -a 256 -c - \
    && chmod a+x "/usr/local/bin/sshb0t"

  echo "sshb0t installed!"

  sshb0t --once \
    --user rodolfo2488
}

install_nvimfiles() {
  echo "Updating pip..."
  pip3 install --upgrade pip

  echo "Installing python-client for neovim..."
  pip3 install neovim
  pip2 install neovim

  echo "Adding yamllint for neomake..."
  pip2 install -q yamllint
  pip3 install -q yamllint

  echo "Installing neovim in npm..."
  npm install -g neovim

  echo "Installing neovim in gem..."
  gem install neovim

  if [[ -f ${HOME}/.config/vim ]]; then
    echo "removing ~/.config/vim dir && ~/.config/nvim"
    rm -rf "${HOME}/.config/vim"
    rm -rf "${HOME}/.config/nvim"
    rm -rf "${HOME}/*.vim"
  else
    clone_if_not_exist https://github.com/luan/nvim "${HOME}/.config/nvim"
  fi

  echo "Adding configuration to nvim..."
  mkdir -p "${HOME}/.config/nvim/user"
  ln -sf "$(pwd)/before.vim" "${HOME}/.config/nvim/user/before.vim"
  ln -sf "$(pwd)/plug.vim" "${HOME}/.config/nvim/user/plug.vim"
  ln -sf "$(pwd)/after.vim" "${HOME}/.config/nvim/user/after.vim"

  echo "Copy snippets..."
  mkdir -p "${HOME}/.vim/UltiSnips"

  echo "Symlink the go.snippets to .vim/UltiSnips..."
  ln -sf "$(pwd)/go.snippets" "${HOME}/.vim/UltiSnips"
}

install_go_deps() {
  echo "Installing hclfmt..."
  GOPATH="${HOME}/go" go get -u github.com/fatih/hclfmt

  echo "Installing ginkgo..."
  GOPATH="${HOME}/go" go get -u github.com/onsi/ginkgo/ginkgo

  echo "Installing gomega..."
  GOPATH="${HOME}/go" go get -u github.com/onsi/gomega

  echo "Installing counterfeiter..."
  GOPATH="${HOME}/go" go get -u github.com/maxbrunsfeld/counterfeiter

  echo "Installing cf-target..."
  GOPATH="${HOME}/go" go get -u github.com/dbellotti/cf-target
}

install_colorschemes() {
  echo "Cloning colorschemes..."
  clone_if_not_exist https://github.com/chriskempson/base16-shell.git "${HOME}/.config/colorschemes"
}

install_tmuxfiles() {
  set +e
    tmux list-sessions # this exits 1 if there are no sessions

    if [ $? -eq 0 ]; then
      echo "If you'd like to update your tmux files, please kill all of your tmux sessions and run this script again."
      exit 1
    else
      clone_if_not_exist "https://github.com/luan/tmuxfiles" "${HOME}/workspace/tmuxfiles"
      "${HOME}/workspace/tmuxfiles/install"
    fi
  set -e
}

main "$@"
