---
layout: default
title: "Photos"
permalink: /photos/
class: photography-layout
custom_css: ["photography"]
---
<div class="site-container">
  
  <h1 style="margin-top: 0;">Photos</h1>

  <div class="masonry-grid" style="margin-top: var(--space-sm);">
    {% assign feed_items = site.photos | concat: site.albums | sort: "date" | reverse %}
    {% for item in feed_items %}
      {% if item.collection == 'photos' %}
        <!-- Photo Card -->
        <div class="photo-card" 
             data-slug="{{ item.slug }}"
             data-title="{{ item.title | escape }}" 
             data-desc="{{ item.description | escape }}" 
             data-img-url="{{ item.image | relative_url }}" 
             data-original-url="{{ item.image | relative_url }}"
             data-camera="{{ item.camera | default: '' | escape }}"
             data-lens="{{ item.lens | default: '' | escape }}"
             data-aperture="{{ item.aperture | default: '' | escape }}"
             data-shutter="{{ item.shutter | default: '' | escape }}"
             data-iso="{{ item.iso | default: '' | escape }}"
             data-focal="{{ item.focal | default: '' | escape }}"
             data-location="{{ item.location | default: '' | escape }}"
             data-date="{{ item.date | date: '%B %d, %Y' }}"
             data-tags="{{ item.tags | join: ',' | escape }}">
          
          <img src="{{ item.image | relative_url }}" 
               alt="{{ item.title | escape }}" 
               {% if forloop.first %}
                 fetchpriority="high"
               {% else %}
                 loading="lazy"
               {% endif %}>

          <div class="photo-overlay">
            <div class="photo-overlay-content">
              <div class="photo-overlay-info">
                <span class="photo-title">{{ item.title }}</span>
                {% if item.location %}
                <span class="photo-location">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                    <circle cx="12" cy="10" r="3"></circle>
                  </svg>
                  {{ item.location }}
                </span>
                {% endif %}
              </div>
              {% if item.camera %}
              <div class="photo-camera-icon" title="{{ item.camera }}">
                <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path>
                  <circle cx="12" cy="13" r="4"></circle>
                </svg>
              </div>
              {% endif %}
            </div>
          </div>
        </div>
      {% elsif item.collection == 'albums' %}
        <!-- Album Stack Card -->
        {% assign album_photos = site.photos | where: "album", item.slug | sort: "date" | reverse %}
        
        {% assign cover_photo = "" %}
        {% if item.coverPhoto %}
          {% assign cover_photo = album_photos | where: "slug", item.coverPhoto | first %}
        {% endif %}
        
        {% if cover_photo == "" or cover_photo == nil %}
          {% assign cover_photo = album_photos | first %}
        {% endif %}

        <article class="album-card">
          <a href="{{ item.url | relative_url }}" class="album-cover-wrapper">
            {% if cover_photo %}
              <img src="{{ cover_photo.image | relative_url }}" alt="{{ item.title }} Cover" class="album-cover" loading="lazy">
              
              <!-- Album Cover Badge (visible in normal state, fades out on hover) -->
              <div class="album-cover-badge">
                <svg viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path>
                </svg>
                <span>{{ album_photos.size }}</span>
              </div>

              <!-- Hover Overlay -->
              <div class="photo-overlay">
                <div class="photo-overlay-content">
                  <div class="photo-overlay-info">
                    <span class="photo-title">{{ item.title }}</span>
                    <span class="photo-location">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:12px; height:12px;">
                        <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
                      </svg>
                      Collection
                    </span>
                  </div>
                  <div class="photo-camera-icon" style="display: flex; align-items: center; gap: 4px;" title="{{ album_photos.size }} photos">
                    <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"></path>
                    </svg>
                    <span style="font-family: var(--font-mono); font-size: var(--text-xs); font-weight: 700;">{{ album_photos.size }}</span>
                  </div>
                </div>
              </div>
            {% else %}
              <div class="album-cover-placeholder">
                <span class="mono">Empty Album</span>
              </div>
            {% endif %}
          </a>
        </article>
      {% endif %}
    {% else %}
      <p class="mono" style="grid-column: 1/-1; text-align: center; color: var(--text-secondary);">No photos or albums published yet.</p>
    {% endfor %}
  </div>

</div>

{% include photography_lightbox.html %}
