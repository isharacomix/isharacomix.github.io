---
layout: base
title: Home
---

Barry Peddycord III
===================
Welcome to my personal website and interactive blog! This is where I'll be putting playable projects and demos that I've made while teaching myself how to do things like make old-fashioned NES and Game Boy games.


Newest Content
==============
<table class="table table-hover table-striped">

<tr>
 <th>Post Title</th>
 <th>Date</th>
</tr>

{% for p in site.data.pages %}
<tr>
            <td><a href="{{p.type}}s/{{p.shortname}}">{{ p.name }}</a></td>
            <td><span class="date"><span class="glyphicon glyphicon-calendar"></span><time datetime="{{p.date|date:"%F"}}">{{p.date|date:"%b %d, %Y"}}</time></span></td>
</tr>
{% endfor %}

</table>



