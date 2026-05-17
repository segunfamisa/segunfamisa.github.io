---
layout: page
title: Home
permalink: /
class: home
---

# Segun Famisa

I build software, write about engineering, and keep notes on the internet.

I am interested in thoughtful tools, Android, developer experience, and the small design choices that make technology feel easier to live with.

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
  {% for item in site.social %}
    <a href="{{ item.url | relative_url }}">↗ {{ item.title }}</a>
  {% endfor %}
</nav>
