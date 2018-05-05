---
title: "{{ replace .TranslationBaseName "-" " " | title }}"
description: "no description available"
date: {{ .Date }}
draft: true
include_toc: true
show_comments: false
url: "{{ "post/" }}{{ now | md5 }}{{ ".html" }}"
outputs:
  - html
tags : 
---


<!--more-->
