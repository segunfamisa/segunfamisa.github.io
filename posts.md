---
layout: page
title: Posts
permalink: /posts/
class: posts
---

# Posts

{% if site.posts.size > 0 %}
<ol class="post-list">
  {% for post in site.posts %}
    <li>
      <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%b %-d, %Y" }}</time>
      <div>
        <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
        {% if post.tags.size > 0 %}
          <span class="post-tags">
            {% for tag in post.tags %}
              {% assign tag_slug = tag | slugify %}
              <a href="{{ '/tags/' | append: tag_slug | append: '/' | relative_url }}">{{ tag }}</a>
            {% endfor %}
          </span>
        {% endif %}
      </div>
    </li>
  {% endfor %}
</ol>
{% else %}
<p>No posts yet.</p>
{% endif %}
