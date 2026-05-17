---
layout: page
title: Tags
permalink: /tags/
class: tags-page
---

# Tags

{% if site.tags.size > 0 %}
<ol class="tag-list">
  {% assign tags = site.tags | sort %}
  {% for tag in tags %}
    {% assign tag_name = tag[0] %}
    {% assign tag_slug = tag_name | slugify %}
    {% assign posts = tag[1] %}
    <li>
      <a href="{{ '/tags/' | append: tag_slug | append: '/' | relative_url }}">{{ tag_name }}</a>
      <span>{{ posts.size }}</span>
    </li>
  {% endfor %}
</ol>
{% else %}
<p>No tags yet.</p>
{% endif %}
