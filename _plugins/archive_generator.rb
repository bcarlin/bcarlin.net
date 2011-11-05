require "set"
require "date"

module Jekyll

  class ArchiveIndex < Page
    def initialize(site, base, dir)
      @site = site
      @base = base
      @dir = dir
      @name = "index.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_includes'), 'archive_index.html')

      archive_title_prefix = site.config['category_title_prefix'] || 'Archive: '
      self.data['title'] = archive_title_prefix
    end
  end
  
  class YearArchiveIndex < ArchiveIndex
    def initialize(site, base, dir, year)
      super(site, base, dir)
      self.data['year'] = year
      self.data['title'] << "#{year}"
      @dir = File.join(@dir, year)
    end
  end
  
  class MonthArchiveIndex < ArchiveIndex
    def initialize(site, base, dir, year, month)
      super(site, base, dir)
      self.data['year'] = year
      self.data['month'] = month
      self.data['title'] << "#{Date::MONTHNAMES[month.to_i]} #{year}"
      @dir = File.join(@dir, year, month)
    end
  end

  class ArchiveGenerator < Generator
    safe true
    
    def generate(site)
      
      dir = site.config['archive_dir'] || 'archive'
      
      y_m_list = site.posts.inject({}) do |y_m_list, post|
        (y_m_list[post.date.year.to_s] ||= Set.new) << "%02d" % post.date.month
        y_m_list 
      end
      
      y_m_list.each_pair do |(year, months)|
        
        year_index = YearArchiveIndex.new(site, site.source, dir, year)
        site.pages << year_index
        
        months.each do |month|
          month_index = MonthArchiveIndex.new(site, site.source, dir, year, month)
          site.pages << month_index
        end
        
      end
    end
  end

end