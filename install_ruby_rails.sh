#!/bin/bash

VER_RUBY=2.2.1
VER_RAILS=4.2.1

INSTALL_NODEJS=0

set -e
set -o nounset

clear
c_err='\033[1;31m'
c_warn='\033[1;35m'
c_inf='\033[1;36m'
c_cmd='\033[1;32m'
c_clr='\033[0m'

print_help(){
  echo "
Usage: $0 [-f]
Parameters:
  -h Help.
  -f Force mode.
     Remove dirs ~/.rbenv and ~/.gem before install.
"
}

echo_color() {
  mess=${1:-''}
  color=${2:-$c_inf}
  echo -e "${color}${mess}${c_clr}"
}

echo_info() {
    mess=${1:-''}
    insert_empty_line_before=${2:-0}
    insert_empty_line_after=${3:-0}
    color=${4:-$c_inf}
    [ -z "$insert_empty_line_before" -o "$insert_empty_line_before" == '0' ] || echo
    echo_color "$mess" $color
    [ -z "$insert_empty_line_after" -o "$insert_empty_line_after" == '0' ] || echo
}

echo_cmd() {
    mess=${1:-''}
    insert_empty_line_before=${2:-1}
    insert_empty_line_after=${3:-0}
    color=${4:-$c_cmd}
    echo_info "$mess" $insert_empty_line_before $insert_empty_line_after $color
}

exit_if_error() {
    local status=${1:-0}
    local mess=$(2:-'please check')
    if [ "$s" != '0' ]; then 
	echo_color "Error: $mess" $c_err
	exit $status
    fi
}

remove_all() {
  if [ -d ~/.rbenv ]; then 
    echo_cmd 'rm -rf ~/.rbenv'
    rm -rf ~/.rbenv
    echo_cmd 'rm -rf ~/.gem' 0
    rm -rf ~/.rbenv
  fi
}

proces_input_params() {
  while getopts ":hf" opt; do
    case $opt in
      f)
        echo_info 'Force mode' 1 0 $c_warn
        remove_all
        ;;
      h|*)
        print_help
        exit 1
        ;;
    esac
  done
  shift $((OPTIND - 1))
}

show_install_mess(){
  echo_info "Ruby:  $VER_RUBY"
  echo_info "Rails: $VER_RAILS"
}

show_start_mess(){
  echo_info "Installing"
  show_install_mess
}

reload_profile() {
  [ -f ~/.bash_profile ] && source ~/.bash_profile
}

install_sys_libs() {
  #Install necessary soft
  echo_cmd "sudo apt-get update -qq"
  echo sudo apt-get update -qq
  echo_cmd "sudo apt-get install -qq -y ..."
  sudo apt-get install -qq -y git-core curl zlib1g-dev     \
    build-essential libssl-dev libreadline-dev libyaml-dev \
    libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev        \
    libcurl4-openssl-dev python-software-properties libffi-dev
}

add_profile2bashrc() {
  grep -q ".bash_profile" ~/.bashrc || echo '[ -f ~/.bash_profile ] && source ~/.bash_profile' >> ~/.bashrc
}

install_rbenv() {
  #install rbenv
  if [ ! -d ~/.rbenv ]; then
    echo_cmd 'git clone https://github.com/sstephenson/rbenv.git ~/.rbenv'
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  fi
  [ ! -f ~/.bash_profile ] && touch ~/.bash_profile
  grep -q ".rbenv"     ~/.bash_profile || echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  grep -q "rbenv init" ~/.bash_profile || echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
  reload_profile

  #check install
  t=$(type rbenv) || exit_if_error $? "check install rbenv"
}

install_plugin_rbenv_ruby_build() {
  #install ruby-build
  if [ ! -d ~/.rbenv/plugins/ruby-build ]; then
    echo_cmd 'git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build'
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  fi
  grep -q ruby-build ~/.bash_profile || echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
  reload_profile
}

install_plugin_rbenv_gem_rehash() {
  #install rbenv-gem-rehash
  #Never run rbenv rehash again. This rbenv plugin automatically runs rbenv rehash every time you install or uninstall a gem.
  if [ ! -d ~/.rbenv/plugins/rbenv-gem-rehash ]; then
    echo_cmd 'git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash'
    git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
  fi
}


install_ruby() {
  #install and check ruby version
  if [ ! -d ~/.rbenv/versions/$VER_RUBY ]; then
    echo_cmd "rbenv install $VER_RUBY"
    rbenv install "$VER_RUBY"
  fi

  echo_cmd "rbenv global $VER_RUBY"
  rbenv global "$VER_RUBY"

  t=$(type ruby) || exit_if_error $? "check install Ruby"
}

install_gem_bundler() {
  #install gems localy
  [ ! -f ~/.gemrc ] && touch ~/.gemrc
  grep -q "gem: --no-ri --no-rdoc" ~/.gemrc || echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
  echo_cmd 'gem install bundler'
  gem install bundler
}

install_rails() {
  #install gem rails
  echo_cmd "gem install rails -v $VER_RAILS"
  gem install rails -v "$VER_RAILS"

  t=$(type rails) || exit_if_error $? "check install Rails"
}

check_install() {
  echo_info 'Please check' 1 0 $c_warn
  show_install_mess
  echo_cmd 'ruby -v' 0
  ruby -v
  echo_cmd "rails -v" 0
  rails -v
  echo_cmd "nodejs -v" 0
  nodejs -v
  echo_cmd "npm -v" 0
  npm -v
}

install_nodejs() {
  echo_info 'curl -sL https://deb.nodesource.com/setup | sudo bash -'
  curl -sL https://deb.nodesource.com/setup | sudo bash -
  sudo apt-get install -y nodejs npm
}

show_start_mess
proces_input_params $*
install_sys_libs
#install ruby
add_profile2bashrc
install_rbenv
install_plugin_rbenv_gem_rehash
install_plugin_rbenv_ruby_build
install_ruby
install_gem_bundler
install_rails
install_nodejs

check_install
exit 0

#--------------------------------------------------------
#More details:
#https://gorails.com/setup/ubuntu/14.10
#https://github.com/sstephenson/rbenv
#https://github.com/sstephenson/ruby-build
#https://github.com/sstephenson/rbenv-gem-rehash

#nodejs
#https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#debian-and-ubuntu-based-linux-distributions
#http://developwithguru.com/how-to-install-node-js-and-npm-in-ubuntu-or-mint/
