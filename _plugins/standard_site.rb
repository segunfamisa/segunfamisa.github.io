module StandardSite
  class PublicationPage < Jekyll::Page
    def initialize(site)
      @site = site
      @base = site.source
      @dir = ".well-known"
      @basename = "site.standard.publication"
      @ext = ""
      @name = "site.standard.publication"
      @content = site.config.dig("standard_site", "publication_at_uri").to_s
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
      config = site.config["standard_site"] || {}
      return if config["enabled"] == false
      return if config["publication_at_uri"].to_s.strip.empty?

      site.pages << PublicationPage.new(site)
    end
  end
end
