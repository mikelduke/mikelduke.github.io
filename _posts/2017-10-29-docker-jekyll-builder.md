---
layout: post
title: Docker Jekyll Builder
author: mikel
date: 2017-10-29 19:53:58 -0500
categories:
- blog
tags:

---
I created a new project on Githib [docker-jekyll-builder-git](https://github.com/mikelduke/docker-jekyll-builder-git) for 
a [Docker](https://www.docker.com/) containerized [Jekyll](jekyllrb.com) project builder that I can run 
on a [Heroku](https://heroku.com) free Dyno. I put it together for use as part of a publishing pipeline instead of relying on the 
Github builder. This way I can use whatever plugins I want and can scp the built _site to my existing webhost. 
This lets me use my existing content and avoids having to change the DNS for my domain name.

Most of the other Jekyll builders I've found for Heroku rely on using either Rack or the Jekyll embedded server for 
serving content. Neither of these are really neccessary since it is just static content and any http server should 
do. You could instead use [Apache](https://httpd.apache.org/) or [NGINX](https://www.nginx.com/resources/wiki/).

Running a static blog off an app dyno seems like a waste of resources unless you really need to scale it out 
dynamically. The content could just as easily be hosted on any other webhost or combined with other static sites. You would 
also need to upgrade to at least a hobby dyno ($7/mo) to avoid dyno sleeping for 6hrs/day, and the costs will add up with several sites.

I haven't pushed the Docker image to Docker hub yet, but will once I'm happy with it and make things a little more flexible.

The image requires several environment variables and these can all be configured through Heroku's web ui. Basically
it will check out a git repo, run a bundle install and jekyll build, the scp the result somewhere else. You need to 
set the URLs to use and and SSH key for the transfers. 

It can run as a bare docker image for use locally or on Heroku, instructions are in the 
[readme](https://github.com/mikelduke/docker-jekyll-builder-git/blob/master/README.md) or below. Next step is I want to 
make it run automatically after a push to github. I'll make a php script on my webhost that can be hit from a webhook on 
Github that will then make the rest api call to Heroku and trigger a build.

---

# jekyll-builder-git

Docker image to checkout a git repo, run a jekyll build, and the SCP the generated _site folder to 
somewhere else.

This lets you use a short lived free Heroku one-off dyno to build a Jekyll app that is hosted somewhere else.

Uses docker image jekyll/builder from https://github.com/jekyll/docker

### Environment Variables
Set these variables in a run command or elsewhere:
* GIT_HOST - Hostname for git repo
* GIT_REPO - Path to git repo
* SCP_HOST - Hostname for SCP destination
* SCP_DEST - SCP Copy Destination
* KEY - Private key for Git over SSH and SCP

# Heroku
* Create a new app
``` heroku create jekyll-builder ```
* Push the Docker Image
``` heroku container:push builder --app jekyll-builder ```
* Create the Environment variables above in the Heroku admin console
* Run the builder
``` heroku run -a jekyll-builder --type builder bash build.sh ```

## Heroku Trigger Script

The script ```run-heroku-jekyll-build.sh``` is an example Heroku API curl request to trigger the 
jekyll builder. 

* Set your app name in the APP_ID_OR_NAME variable
* Get a Heroku API Token by running ```heroku auth:token```
* Set TOKEN= to the token
* Run ```./run-heroku-jekyll-build.sh``` to trigger a build. 
* Logs can be viewed from the Heroku Dev console log viewer. Make sure you have it up when 
running the build, the logs are not saved.

# Docker

* Docker Build
``` docker build -t jekyll-builder-git . ```
* Sample Docker Run Command
```
docker run \
  --rm \
  -it \
  -e "GIT_HOST=github.com" \
  -e "SCP_HOST=yoursite.com" \
  -e "GIT_REPO=https://something" \
  -e "SCP_DEST=you@yoursite.com:/path/to/dest/" \
  -e "KEY=-----BEGIN RSA PRIVATE KEY-----
1234567890
-----END RSA PRIVATE KEY-----"  \
  jekyll-builder-git
```
