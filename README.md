# Git2Serve

A container for deploying static websites from git using h2o shipped with NodeJS. [Docker Hub](https://hub.docker.com/r/connorhartley/git2serve/)

- h2o is a modern and fast http server, so it's ideal for this kind of deployment
- nodejs provides a variety of tooling you can use to build your project

## Usage

Simple run: `docker run -p 80:80 -e WEBSITE_ID=foobar -e WEBSITE_REPO=https://github.com/foo/bar.git connorhartley/git2serve`

You can mount a volume that uses the hosts ssh key for git to clone / pull from like so.

Private repository run: `docker run -p 80:80 -e WEBSITE_ID=foobar -e WEBSITE_REPO=https://github.com/foo/bar.git -e GIT_SSH_FILE=/key -v ~/.ssh/id_rsa:/key:ro connorhartley/git2serve`

As port 80 is already exposed you can use it in conjunction with [nginx-proxy](https://github.com/jwilder/nginx-proxy) like so.

Proxied run: `docker run -e VIRTUAL_HOST=foobar.com -e WEBSITE_ID=foobar -e WEBSITE_REPO=https://github.com/foo/bar.git connorhartley/git2serve`

## Setup

As long as the project you're cloning contains a configuration for h2o at `.h2o/h2o.config` it should be served.

This will run `npm start` before serving, allowing you to build the project, move files, etc.

This also contains support for [pac](https://www.npmjs.com/package/pac) which will use the modules from the `.modules`
directory and `npm rebuild`, instead of fetching the modules from `npm install`.
