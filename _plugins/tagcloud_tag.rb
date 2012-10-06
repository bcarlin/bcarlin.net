module Jekyll
  class TagCloud < Liquid::Tag
    safe = true
    
    def render(context)
      tags = context.registers[:site].tags
      tag_dir = context.registers[:site].config['tag_dir']
      
      tag_counts = tags.map {|(tag, post_list)| [tag, post_list.length] }
      (_, min_count), (_, max_count) = tag_counts.minmax_by {|(tag, count)| count }
            
      tag_counts.sort_by{rand}.inject("") do |html, (tag, count)|

        weight = Float(count-min_count)/[max_count-min_count, 1].max
        tag_class = get_class_for weight
        
        html << "<a class=\"#{tag_class}\" href=\"#{tag_dir}/#{tag}.html\">#{tag.pretty_print}</a> "
        
      end
    end
    
    def get_class_for(weight)
      classes = %w{ xxs xs s l xl xxl }
      
      return classes[-1] if weight == 1.0
      classes.at ( weight / (1.0 / classes.count) ).to_i
    end
  end
end

Liquid::Template.register_tag('tag_cloud', Jekyll::TagCloud)