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

if [ -d $PROJECT_PATH ]; then
  rm -rf $PROJECT_PATH
fi

if [ -d $PROJECT_TEMP ]; then
  rm -rf $PROJECT_TEMP
fi

mkdir -p $PROJECT_PATH
mkdir -p $PROJECT_TEMP

cd $PROJECT_TEMP

GITHUB_ASSET_ID=$(curl -sSL "https://api.github.com/repos/${GITHUB_PROJECT}/releases/${GITHUB_VERSION}?access_token=${GITHUB_TOKEN}" | grep -B 1 "\"name\": \"${GITHUB_FILE}\"" | head -1 | sed 's/.*"id": \(.*\),/\1/')
curl -vLJO -H 'Accept: application/octet-stream' "https://api.github.com/repos/${GITHUB_PROJECT}/releases/assets/${GITHUB_ASSET_ID}?access_token=${GITHUB_TOKEN}" -o "${GITHUB_FILE}"


##################################
# Unpack archive.
##################################

echo "g2s : Unpack ($GITHUB_FILE)"

cd ~

if [ -f $PROJECT_BASE/$PROJECT_TEMP/$GITHUB_FILE ]; then
  tar xf "$PROJECT_BASE/$PROJECT_TEMP/$GITHUB_FILE" -C "$PROJECT_BASE/$PROJECT_PATH"
fi

##################################
# Serve the project.
##################################

echo "g2s : Serving ($PROJECT_ID) ($PROJECT_VERSION)"

cd ~

sudo h2o --conf "$PROJECT_BASE/$PROJECT_CONFIG" &
