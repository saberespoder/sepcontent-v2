module BlogHelpers
  def categories
    sepcontent.categories.map { |c| OpenStruct.new(c[1]) }
  end

  def articles
    sepcontent.articles.map { |a| OpenStruct.new(a[1]) }
  end

  def related_articles(article, limit = 3)
    article_tags       = article.tags
    article_categories = article_categories(article)

    related = if article_tags.any?
      # Fetch articles with tags similar to the current article tags
       article_tags.map { |t| blog.tags[t] }
    elsif article_categories.any?
      # Fetch articles with categories similar to the current article tags
      blog.articles.select { |a| (article_categories(a) & article_categories(article)).any? }
    end

    filter_related(article, related, limit) if related.any?
  end

  private

  def sepcontent
    @sepcontent ||= data.sepcontent
  end

  def article_categories(article)
    category_array(article.data[:categories])
  end

  def category_array(categories)
    (categories || "Uncategorized").split(/,\s*/)
  end

  def filter_related(article, collection, limit)
    collection
      .flatten
      .uniq
      .reject { |a| a == article }
      .shuffle
      .take(limit)
  end
end
