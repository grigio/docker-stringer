#!/bin/bash
#
# Deploy.sh
#

HOME="/home/stringer"
APPDIR="/home/stringer/stringer"

show() {
  echo -e "\n\e[1;32m>>> $1\e[00m"
}

system_setup () {
  show "System setup, packages, gems, sys users.."
  sudo apt-get update
  sudo apt-get install -y git psmisc libxml2-dev libxslt-dev libcurl4-openssl-dev libpq-dev libsqlite3-dev build-essential nodejs postgresql screen make  libcurl4-openssl-dev build-essential ruby1.9.1 ruby1.9.1-dev
  sudo gem install bundler rake foreman --no-rdoc --no-ri
  sudo useradd  --shell /bin/bash --home-dir $HOME -m -p `openssl passwd strpass` stringer
}

system_run () {
  show "System daemons start"
  sudo /etc/init.d/postgresql start
  sudo cron
}


app_setup () {
  system_run
  show "App db, cron, env"

  # prepare db
  sudo -u postgres psql -c "CREATE ROLE stringer NOCREATEDB LOGIN encrypted password 'strpass'"
  sudo -u postgres createdb -O stringer stringer_live

  # get the code
  sudo -u stringer git clone https://github.com/swanson/stringer.git $APPDIR
  cd $APPDIR && sudo -u stringer bundle install --deployment

  # production app settings
  cd $APPDIR && sudo -u stringer echo -e "PORT=5000\nSTRINGER_DATABASE=stringer_live\nSTRINGER_DATABASE_USERNAME=stringer" > .env

  # db migrations  
  cd $APPDIR && sudo -u stringer foreman run bundle exec rake db:migrate

  # cronjob
  echo "*/10 * * * *  cd $APPDIR && foreman run bundle exec rake fetch_feeds" | sudo -u stringer crontab -
}

app_run () {
  system_run
  show "App start"
  cd $APPDIR && sudo -u stringer foreman start
}

$1
