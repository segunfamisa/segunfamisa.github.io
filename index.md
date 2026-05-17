---
layout: page
title: Home
permalink: /
class: home
---

# Segun Famisa

Hi 👋🏾 I'm Segun.

I build software, write about engineering, and I'm based in Berlin.

{% if site.posts.size > 0 %}
## Recent

<ol class="recent-list">
  {% assign recent_limit = site.home.recent_posts | default: 3 %}
  {% for post in site.posts limit: recent_limit %}
    <li>
      <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%b %-d, %Y" }}</time>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ol>
{% endif %}

<nav class="social-links" aria-label="Social links">
  <span>elsewhere:</span>
  {% for item in site.social %}
    <a href="{{ item.url | relative_url }}">{{ item.title }}</a>
  {% endfor %}
</nav>
