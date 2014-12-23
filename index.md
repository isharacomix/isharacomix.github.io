---
layout: base
title: Home
---

Hello World
===========
Welcome to my interactive blog and or workshop.


Newest Content
==============
{% for p in site.data.pages limit:5 %}
  <div class="panel panel-default">
    <a href="{{p.type}}s/{{p.shortname}}">{{p.name}}</a>
  </div>
{% endfor %}

