#!/bin/bash

##################################
# Download archived distribution.
##################################

PROJECT_BASE="$PROJECT_ID/$PROJECT_VERSION"

echo "g2s : Download ($GITHUB_PROJECT) ($GITHUB_VERSION)"

# Make the project directory if it doesn't exist already.

cd ~

if [ -d $PROJECT_BASE ]; then
  cd $PROJECT_BASE
else
  mkdir -p $PROJECT_BASE
  cd $PROJECT_BASE
fi

ASSET_RESPONSE=$(curl -sH "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$GITHUB_PROJECT/releases/$GITHUB_VERSION)
ASSET_DIST_ID=$(echo "$ASSET_RESPONSE" | grep -C3 "name.:.\+$GITHUB_FILE" | grep -w id | tr : = | tr -cd [:digit:])
ASSET_CONF_ID=$(echo "$ASSET_RESPONSE" | grep -C3 "name.:.\+$GITHUB_CONF" | grep -w id | tr : = | tr -cd [:digit:])

curl -LJO -H 'Accept: application/octet-stream' https://api.github.com/repos/$GITHUB_PROJECT/releases/assets/$ASSET_DIST_ID?access_token=$GITHUB_TOKEN
curl -LJO -H 'Accept: application/octet-stream' https://api.github.com/repos/$GITHUB_PROJECT/releases/assets/$ASSET_CONF_ID?access_token=$GITHUB_TOKEN

##################################
# Unpack archive and move files.
##################################

echo "g2s : Unpack ($GITHUB_FILE)"

cd ~

if [ -f $PROJECT_BASE/$GITHUB_FILE ]; then
  sudo rm -rf /var/www/
  sudo mkdir -p /var/www/
  sudo tar -zxf "$PROJECT_BASE/$GITHUB_FILE" -C /var/www/
fi

if [ -f $PROJECT_BASE/$GITHUB_CONF ]; then
  sudo rm -rf /etc/h2o/
  sudo mkdir -p /etc/h2o/
  sudo cp "$PROJECT_BASE/$GITHUB_CONF" /etc/h2o/$GITHUB_CONF
fi

##################################
# Serve the project.
##################################

echo "g2s : Serving ($PROJECT_ID) ($PROJECT_VERSION)"

cd ~

sudo h2o --conf /etc/h2o/$GITHUB_CONF
