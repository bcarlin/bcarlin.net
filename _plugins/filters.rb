module Jekyll
  module CustomFilters
    def pretty_display(input)
      input.pretty_print
    end
  end
end

Liquid::Template.register_filter(Jekyll::CustomFilters)

