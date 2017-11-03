---
layout: post
title: Converting to Jekyll from Wordpress
author: mikel
date: 2017-11-03 16:19:54 -0500
categories:
- blog
tags:

---
Converting from Wordpress to Jekyll was pretty easy. My wordpress was self hosted, so I had access to the database
info I needed to export my old site.

# Export
I followed the [Jekyll guide](http://import.jekyllrb.com/docs/wordpress/) where you run the 
ruby jekyll-importer with your database info. You might need to update ruby and install the 
jekyll-import gem and some other dependencies, and may need sudo for some environments.
```
apt-get install ruby-full
gem install jekyll
gem install jekyll-import
gem install mysql2
gem install bundler
```
```
ruby -rubygems -e 'require "jekyll-import";
    JekyllImport::Importers::WordPress.run({
      "dbname"   => "",
      "user"     => "",
      "password" => "",
      "host"     => "localhost",
      "port"     => "3306",
      "socket"   => "",
      "table_prefix"   => "wp_",
      "site_prefix"    => "",
      "clean_entities" => true,
      "comments"       => true,
      "categories"     => true,
      "tags"           => true,
      "more_excerpt"   => true,
      "more_anchor"    => true,
      "extension"      => "html",
      "status"         => ["publish"]
    })'
```
I couldn't get this to run from the Dreamhost shell, but I had a Raspberry Pi I could run it on instead, since
I didn't want to have to run through the [Windows Jekyll install](https://jekyllrb.com/docs/windows/) process. 
Now I use a Docker container to build on my Windows machine instead. No install needed.

After exporting, I was able to build the site using all the default settings and had a folder called _posts

The wordpress posts all exported as html files containing the html from each post. Some of these might 
need additional jekyll plugins or include files to display properly, or some manual tweeking. In my case, 
a lot of the html links didn't format correctly, and the youtube embeds didn't display.
```
cd export-folder
jekyll new .
bundle exec jekyll build
```
This should create a _site folder in the current directory with the build site. Now start looking for new themes 
and customizing the site.

# Customize
The first thing I did was to configure some of the settings in _config.yaml like title, email, and baseurl. I also
deleted a lot of the stub pages that were exported from Wordpress. Those were just there to hold the links on my
title bar, but jekyll made them into empty pages.

After that, look for a theme or customize one. I didn't see any premade ones I really liked so I just made some 
tweaks to the default minima theme. To modify the current theme, you copy the files you want to override from 
theme's install to your project in a corresponding folder. As an example, [Minmina](https://github.com/jekyll/minima) 
has [_includes/header.html](https://github.com/jekyll/minima/blob/master/_includes/header.html), if you have your own
```_includes/header.html``` it will be used instead.

## Youtube Embeds
One thing that was missing was the youtube video embeds I had. Using wordpress you only had to include a link to the 
video on it's own line and it would automatically add the html required. 

Adding extra html for use in the markdown files is straight forward. I added an include file 
[_includes/youtubeEmbed.html](https://github.com/mikelduke/mikelduke.github.io/blob/master/_includes/youtubeEmbed.html)
with the youtbe html inside: 
```
<iframe width="560" height="315" src="https://www.youtube.com/embed/{{ include.id }}" frameborder="0" allowfullscreen></iframe>
```
And can include it in a post like this:
```
{% include youtubeEmbed.html id="VcFI91r2zU4" %}
```

# Use Docker for builds
If you are on Linux/macos this might not be needed, since ruby installs are pretty easy.

1. Install [Docker](https://www.docker.com/) for your os
1. Share the windows folder path with your site to VirtualBox if needed
1. Run the Docker build
```
docker run -it --volume PATH_TO_PROJECT:/srv/jekyll jekyll/builder jekyll build
```
1. If on linux/mac and not using a VM, you can cd to the jekyll folder and use $PWD instead
```
docker run -it --volume $PWD:/srv/jekyll jekyll/builder jekyll build
```

This will generate the _site, now you can either scp/ftp it to a webhost or run it locally from any http server. 

If you want to run the site from the Docker image using the jekyll server:
```
docker run -it --volume /git/jekyll-temp:/srv/jekyll -p 4000:4000 --expose 4000 jekyll/builder sh -c "bundle install && bundle exec jekyll serve --host=0.0.0.0"
```
If using VirtualBox, remember to enable port forwarding for port 4000
![VirtualBox Port-Forward]({{ "/assets/images/virtual-box-port-forwarding.png" | absolute_url }})

## Github pages
If you dont want to have to build anything, you can just push the git repo to git hub with a name like username.github.io
and they will autodetect and build the site out for you at https://username.github.io

It is nice to build locally first to preview the changes. Having a build setup also lets you deploy the site to any other webhost too.
