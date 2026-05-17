# Minimal Jekyll

A small custom Jekyll site for a personal homepage and blog.

## Run locally

```sh
bundle install
bundle exec jekyll serve
```

Then open <http://localhost:4000>.

## Search

Search is powered by Simple Jekyll Search. Jekyll generates `search.json` during the normal build, so there is no npm install or post-build indexing step.

Search is controlled in `_config.yml` under `search`.
The search modal opens from the nav or with `Cmd+K` / `Ctrl+K`. Set `search_modal: false` in a page's front matter to hide the modal on that page.

## Analytics

PostHog analytics are optional. Set your project API key in `_data/settings.yml`:

```yaml
posthog: phc_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

When `posthog` is blank, the analytics script is not included.

## Home Page

The number of recent posts shown on the home page is configured in `_config.yml`:

```yaml
home:
  recent_posts: 3
```

## SEO

Each page can override SEO metadata with front matter:

```yaml
description: Short page summary for search results and link previews.
image: /assets/images/preview.png
canonical_url: https://example.com/custom-url/
noindex: true
```

Posts also emit article metadata for publish date, modified date, and tags.
Use `modified_date` in post front matter when you want article updated-time metadata.

## AT Protocol

AT Protocol support is optional. Configure it in `_config.yml`:

```yaml
atproto:
  enabled: true
  handle: example.com
  did: did:plc:example
```

When `enabled` and `did` are set, Jekyll generates `/.well-known/atproto-did` for Bluesky custom-domain handle verification. When a handle or `profile_url` is set, SEO metadata also includes a `rel="me"` link and JSON-LD `sameAs`.

## Standard.site

Standard.site support is optional. Configure publication verification in `_config.yml`:

```yaml
standard_site:
  enabled: true
  publication_at_uri: at://did:plc:example/site.standard.publication/example
```

When enabled, Jekyll generates `/.well-known/site.standard.publication` with the publication AT-URI.

For post-level `site.standard.document` verification, add the document AT-URI to the post front matter:

```yaml
standard_site:
  document:
    at_uri: at://did:plc:example/site.standard.document/example
```

That emits:

```html
<link rel="site.standard.document" href="at://did:plc:example/site.standard.document/example">
```

## Add a post

Create a Markdown file in `_posts` named like:

```text
2026-05-17-my-post-title.md
```

Use front matter like:

```yaml
---
layout: post
title: My Post Title
slug: my-post-title
date: 2026-05-17 19:30:00 +0200
tags:
  - notes
---
```

The `slug` field is optional. If you omit it, Jekyll derives the slug from the post filename.

Tag pages are generated automatically at `/tags/<tag>/`. The `/tags/` page exists as `tags.md`, and the navigation link is optional:

```yaml
tag_pages:
  show_in_nav: false
```
