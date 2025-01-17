#!/bin/sh

RUBY_VERSION=3.0.0
SCRIPT_USER=$SUDO_USER
TL_BRANCH=master

# Checking if script running with sudo
if [[ $(id -u) -ne 0 ]]
    then echo "Please run with sudo ..."
    exit 1
fi

echo 'Well, here we go! Running the script...'


sudo apt update
sudo apt install -y build-essential libssl-dev zlib1g-dev git
sudo apt autoremove -y
cd /usr/local
git clone http://github.com/rbenv/rbenv.git rbenv
git clone https://github.com/rbenv/rbenv-vars.git rbenv/plugins/rbenv-vars

chgrp -R staff rbenv
chmod -R g+rwxXs rbenv

echo 'export RBENV_ROOT=/usr/local/rbenv' >> /home/"$SCRIPT_USER"/.bashrc
echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /home/"$SCRIPT_USER"/.bashrc
echo 'eval "$(rbenv init -)"' >> /home/"$SCRIPT_USER"/.bashrc

echo 'export RBENV_ROOT=/usr/local/rbenv' >> /home/"$SCRIPT_USER"/.zshrc
echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /home/"$SCRIPT_USER"/.zshrc
echo 'eval "$(rbenv init -)"' >> /home/"$SCRIPT_USER"/.zshrc

echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc
echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /root/.bashrc
echo 'eval "$(rbenv init -)"' >> /root/.bashrc

export RBENV_ROOT=/usr/local/rbenv
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

# Install ruby-build
git clone https://github.com/rbenv/ruby-build.git /root/.rbenv/plugins/ruby-build
git clone https://github.com/rbenv/ruby-build.git /home/"$SCRIPT_USER"/.rbenv/plugins/ruby-build

echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> /root/.bashrc
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> /home/"$SCRIPT_USER"/.bashrc
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> /home/"$SCRIPT_USER"/.zshrc

export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"

# Install Ruby
rbenv install -v "$RUBY_VERSION"
rbenv global "$RUBY_VERSION"

gem install bundler

cd
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install -y yarn
cd
mkdir TodoLegal
cd TodoLegal/
git init
git remote add origin https://github.com/TodoLegal/TodoLegal.git
git pull origin "$TL_BRANCH"
echo "ELASTICSEARCH_URL: ENV["\""ELASTICSEARCH_URL"\""]" >> ~/TodoLegal/config/application.yml
EDITOR="nano" bin/rails credentials:edit
sudo apt-get install -y postgresql-client libpq-dev
bundle install
sudo apt-get install -y dirmngr gnupg
sudo apt-get install -y nginx
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y libnginx-mod-http-passenger
`if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then sudo ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi`
sudo cp Docs/TodoLegal /etc/nginx/sites-enabled/
sudo service nginx restart

sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

chown -R "$SCRIPT_USER":"$SCRIPT_USER" /home/"$SCRIPT_USER"
chown -R "$SCRIPT_USER":root /usr/local/rbenv

