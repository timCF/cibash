#!/bin/sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew cask
brew cask update
brew cask install iterm2 google-chrome firefox atom amethyst slack skype java libreoffice
brew install wget curl elixir node gcc python openssl nginx ruby protobuf
brew install homebrew/versions/mysql56
mix local.hex --force
mix local.rebar --force
apm install language-elixir autocomplete-elixir
npm cache clean
npm install npm -g
npm install phantomjs-prebuilt iced-coffee-script brunch bower -g
sudo chown -R $(whoami) /Library/Ruby/Gems/2.0.0
gem install sass
pip install csv2xlsx
