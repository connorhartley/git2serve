#!/bin/bash

##############################
# Clone the repository.
##############################

echo "git2serve :: Clone"

if [ -d $WEBSITE_ID ]; then
  cd $WEBSITE_ID
  git reset --hard origin/master > /dev/null
  git pull > /dev/null
else
  git clone $WEBSITE_REPO $WEBSITE_ID > /dev/null
fi
echo "Cloned ($WEBSITE_REPO) into ($WEBSITE_ID)."

##############################
# Start the project.
##############################

echo "git2serve :: Start"

# Go to the website directory
cd $WEBSITE_ID

# Support pac production deployment (https://www.npmjs.com/package/pac)
if [ -d ".modules" ]; then
  mkdir -p node_modules
  for f in .modules/*.tgz; do tar -zxf "$f" -C node_modules/; done
  npm rebuild
else
  npm install
fi

echo "Starting ($WEBSITE_ID)"

# The start script. The start script should:
# - Start the application.
# - Start the h2o instance.
npm start
