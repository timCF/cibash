#!/bin/bash
apt-get -y update
apt-get -y upgrade
apt-get -y install make gcc g++ screen wget curl python libreoffice nginx tar zip unzip supervisor
apt-get -y install iconv
wget https://bootstrap.pypa.io/get-pip.py
python ./get-pip.py
pip install csv2xlsx
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get -y install nodejs
npm install npm -g
npm install phantomjs-prebuilt -g
