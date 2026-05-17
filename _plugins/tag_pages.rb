module TagPages
  class TagPage < Jekyll::Page
    def initialize(site, tag)
      @site = site
      @base = site.source
      @dir = File.join("tags", Jekyll::Utils.slugify(tag))
      @basename = "index"
      @ext = ".html"
      @name = "index.html"

      process(@name)
      read_yaml(File.join(@base, "_layouts"), "tag.html")
      data["tag"] = tag
      data["title"] = tag
      data["permalink"] = File.join("/", @dir, "/")
    end
  end

  class Generator < Jekyll::Generator
    safe true

    def generate(site)
      config = site.config["tag_pages"] || {}
      return if config["enabled"] == false

      site.tags.each_key do |tag|
        site.pages << TagPage.new(site, tag)
      end
    end
  end
end
