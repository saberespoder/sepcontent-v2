require "lib/blog_helpers"
helpers BlogHelpers

page "/feed.xml", layout: false

set :slim, { ugly: true, format: :html }
activate :external_pipeline,
  name:    :webpack,
  command: build? ? "./node_modules/webpack/bin/webpack.js --bail -p" : "./node_modules/webpack/bin/webpack.js --watch -d --progress --color",
  source:  ".tmp/dist",
  latency: 1

configure :development do
  activate :livereload
end

activate :blog do |blog|
  blog.permalink = "/articles/{title}.html"
  blog.tag_template = "tag.html"
  blog.calendar_template = "calendar.html"

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

ready do
  sitemap.resources
    .map { |r| (r.data["categories"] || "Uncategorized").split(/,\s*/) }
    .flatten
    .uniq
    .each { |category|
      proxy "/categories/#{category.parameterize}.html", "category.html",
      locals: { category: category }
    }
end
