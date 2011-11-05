require "date"

module Jekyll
  class ArchiveList < Liquid::Tag
    safe = true
    @@result = nil
      
    def render(context)
      return @@result unless @@result.nil?
      
      posts = context.registers[:site].posts
      @archive_dir = context.registers[:site].config['archive_dir']
      
      archive_count = posts.inject({}) do |archive_count, post|
        
        archive_count[post.date.year] ||= {'count' => 0, 'months' => {}}
        archive_count[post.date.year]["months"][post.date.month] ||= 0 
        
        archive_count[post.date.year]['count'] += 1
        archive_count[post.date.year]["months"][post.date.month] += 1
        archive_count 
      end
      
      year_list = archive_count.sort_by{|y|-y[0]}.map do |(year, info)|
        month_list = info['months'].sort_by{|m|-m[0]}.map do |(month, count)|
          make_link(count, year, month)
        end
        make_link(info['count'], year) << month_list.to_html_list
      end
      
      @@result = year_list.to_html_list
    end
    
    def make_link(count, year, month=nil)
      url = "#{@archive_dir}/#{year}"
      url << "/#{"%02d" % month}" unless month.nil?
      
      label = if month.nil? then year.to_s else Date::MONTHNAMES[month] end 
      label += " (#{count})"
      
      return "<a href=\"#{url}\">#{label}</a>"
    end
  end
end

Liquid::Template.register_tag('archives', Jekyll::ArchiveList)