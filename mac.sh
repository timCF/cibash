#!/bin/sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew cask
brew cask update
brew cask install iterm2 google-chrome firefox atom amethyst slack skype java libreoffice thunderbird puush dropbox
brew install wget curl elixir node gcc python openssl nginx ruby protobuf fop
brew install homebrew/versions/mysql56
brew tap homebrew/dupes
brew install grep
mix local.hex --force
mix local.rebar --force
apm install language-elixir autocomplete-elixir language-protobuf atom-jade language-sass
npm cache clean
npm install npm -g
npm install phantomjs-prebuilt iced-coffee-script brunch bower -g
sudo chown -R $(whoami) /Library/Ruby/Gems/2.0.0
gem install sass
pip install csv2xlsx
