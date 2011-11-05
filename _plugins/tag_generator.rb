module Jekyll

  class TagPage < Page
    def initialize(site, base, dir, tag)
      @site = site
      @base = base
      @dir = dir
      
      self.process(@name)
      self.read_yaml(File.join(base, '_includes'), @template)
      self.data['set'] = tag
      self.data['post_list'] = 'tags'
      
      tag_title_prefix = site.config['tag_title_prefix'] || 'Tag: '
      self.data['title'] = "#{tag_title_prefix}#{tag.pretty_print}"
    end
  end

  class TagIndex < TagPage
    def initialize(site, base, dir, tag)
      @name = "#{tag}.html"
      @template =  'html_indexes.html'
      
      super(site, base, dir, tag)
    end
  end
  
  class TagRSS < TagPage
    def initialize(site, base, dir, tag)
      @name = "#{tag}.rss.xml"
      @template = 'rss.xml'
      
      super(site, base, dir, tag)
    end
  end
  
  class TagAtom < TagPage
    def initialize(site, base, dir, tag)
      @name = "#{tag}.atom.xml"
      @template = 'atom.xml'
      
      super(site, base, dir, tag)
    end
  end

  class TagGenerator < Generator
    safe true
    
    def generate(site)
      dir = site.config['tag_dir'] || 'tag'
      feed_dir = site.config['feed_tag_dir'] || 'tag'
      site.tags.keys.each do |tag|
        index = TagIndex.new(site, site.source, dir, tag)
        site.pages << index
        rss = TagRSS.new(site, site.source, feed_dir, tag)
        site.pages << rss
        atom = TagAtom.new(site, site.source, feed_dir, tag)
        site.pages << atom
      end
    end
  end

end