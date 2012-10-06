module Jekyll
  class ProdOnly < Liquid::Block
    def initialize(tag_name, markup, tokens)
       super
    end
  
    def render(context)
      if ENV['JEKYLL_ENV'] == 'prod'
         super
      else
         ''
      end
    end
  end
end

Liquid::Template.register_tag('prod_only', Jekyll::ProdOnly)