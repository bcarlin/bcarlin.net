module Jekyll
  class CategoryPage < Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir = dir
      
      self.process(@name)
      self.read_yaml(File.join(base, '_includes'), @template)
      self.data['set'] = category
      self.data['post_list'] = 'categories'
  
      category_title_prefix = site.config['category_title_prefix'] || 'Category: '
      self.data['title'] = "#{category_title_prefix}#{category.pretty_print}"
    end
  end

  class CategoryIndex < CategoryPage
    def initialize(site, base, dir, category)
      @name = "#{category}.html"
      @template = 'html_indexes.html'

      super(site, base, dir, category)
    end
  end
  
  class CategoryRSS < CategoryPage
    def initialize(site, base, dir, category)
      @name = "#{category}.rss.xml"
      @template = 'rss.xml'

      super(site, base, dir, category)
    end
  end
  
  class CategoryAtom < CategoryPage
    def initialize(site, base, dir, category)
      @name = "#{category}.atom.xml"
      @template = 'atom.xml'

      super(site, base, dir, category)
    end
  end

  class CategoryGenerator < Generator
    safe true
    
    def generate(site)
      dir = site.config['category_dir'] || 'categories'
      feed_dir = site.config['feed_category_dir'] || 'categories'
      site.categories.keys.each do |category|
        index = CategoryIndex.new(site, site.source, dir, category)
        site.pages << index
        rss = CategoryRSS.new(site, site.source, feed_dir, category)
        site.pages << rss
        atom = CategoryAtom.new(site, site.source, feed_dir, category)
        site.pages << atom
      end
    end
  end

end