#!/bin/bash

if [ -z ${WEBSITE_ID+x} ] || [ -z ${WEBSITE_REPO+x} ]; then
  echo "Cannot run script if 'WEBSITE_ID' and 'WEBSITE_REPO' are not specified."
  exit 1
fi

##############################
# Clone the repository.
##############################

if [ -d $WEBSITE_ID ]; then
  cd $WEBSITE_ID
  if [ -n "$GIT_SSH_FILE" ]; then
    ssh-agent bash -c "ssh-add $GIT_SSH_FILE; git reset --hard origin/master > /dev/null; git pull > /dev/null"
  else
    git reset --hard origin/master > /dev/null
    git pull > /dev/null
  fi
else
  cd
  if [ -n "$GIT_SSH_FILE" ]; then
    ssh-agent bash -c "ssh-add $GIT_SSH_FILE; git clone $WEBSITE_REPO $WEBSITE_ID > /dev/null"
  else
    git clone $WEBSITE_REPO $WEBSITE_ID > /dev/null
  fi
fi
echo "Cloned ($WEBSITE_REPO) into ($WEBSITE_ID)"

##############################
# Install the project.
##############################

# Go to the website directory
cd $WEBSITE_ID

# Support pac production deployment (https://www.npmjs.com/package/pac)
if [ -d ".modules/" ]; then
  mkdir -p node_modules > /dev/null
  for f in .modules/*.tgz; do tar -zxf "$f" -C node_modules/ > /dev/null; done
  npm rebuild > /dev/null
else
  npm install > /dev/null
fi

# The start script. The start script can:
# - Build the application.
# - Move files to appropriate places.
npm start

# Move custom h2o configuration (https://github.com/h2o/h2o/wiki#configuration-examples)
if [ -d ".h2o/" ]; then
  sudo mkdir /etc/h2o
  sudo cp .h2o/h2o.conf /etc/h2o/h2o.conf
fi

echo "Installed ($WEBSITE_ID)"

##############################
# Serve the project.
##############################

echo "Serving ($WEBSITE_ID)"

h2o --conf /etc/h2o/h2o.conf
