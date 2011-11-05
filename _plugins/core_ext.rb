class Array
  def to_html_list
    html_items = self.inject("") do |html_items, item| 
      html_items << "<li>#{item}</li>"
      html_items
    end
    return "<ul>#{html_items}</ul>"
  end
end

class String
  def pretty_print
    return self.split("-").map{|part| part[0]=part[0].upcase; part}.join(' ')
  end
end