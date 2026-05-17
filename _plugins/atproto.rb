module Atproto
  class DidPage < Jekyll::Page
    def initialize(site)
      @site = site
      @base = site.source
      @dir = ".well-known"
      @basename = "atproto-did"
      @ext = ""
      @name = "atproto-did"
      @content = site.config.dig("atproto", "did").to_s
      @data = {
        "layout" => nil,
        "sitemap" => false,
        "search" => false
      }
    end

    def output
      @content
    end
  end

  class Generator < Jekyll::Generator
    safe true

    def generate(site)
      config = site.config["atproto"] || {}
      return if config["enabled"] == false
      return if config["did"].to_s.strip.empty?

      site.pages << DidPage.new(site)
    end
  end
end
