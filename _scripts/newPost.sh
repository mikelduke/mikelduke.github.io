#!/bin/bash

FILE=$(date +"%Y-%m-%d")-$1.md
echo "new filename="$FILE

DATE=$(date +"%Y-%m-%d %T %z")
echo $DATE

echo '---
layout: post
title: A title
author: mikel
date: '$DATE'
categories:
- blog
tags:

---
text' > _posts/$FILE

