require "flickraw"
require "yaml"

class Stub
  attr_reader :url_t
  attr_reader :title
  attr_reader :id
  def initialize()
    @url_t = "/images/test_sample.jpg"
    @title = "foo bar (sample)"
    @id = "6371845061"
  end
end

module Jekyll
  class FlickrPhoto < Liquid::Tag
    @@setup = false
    @@picture_list = nil
    
    def setup
      return if @@setup
      return make_stub unless ENV['JEKYLL_ENV'] == 'prod'
      
      setup_flickr
      call_flickr
      
      @@setup = true
    end
    
    def render(context)
      base_dir = context.registers[:site].source
      flickr_conf_file = File.join(base_dir, '_flickr.yml')
      return "" unless File.exists?(flickr_conf_file)
      @flickr_info = YAML::load(File.open(flickr_conf_file))
      
      setup 
      photo = @@picture_list.sample
      #STDERR.puts photo.inspect
      render_html photo
    end
    
    def make_stub
        @@picture_list = [Stub.new]
        @@set_id  = @flickr_info['photoset']
        @@user_id = "69681083@N03"
        @@setup = true
        return
    end
    
    def setup_flickr
      FlickRaw.api_key = @flickr_info['api_key']
      FlickRaw.shared_secret = @flickr_info['shared_secret']
    end
    
    def call_flickr
      STDERR.puts "calling flickr"
      response = flickr.photosets.getPhotos :photoset_id => @flickr_info['photoset'],
                      :extras => 'url_t', :privacy_filter => '1'
      @@set_id = response.id
      @@user_id = response.owner 
      @@picture_list = response.photo
    end
    
    def render_html(photo)
      res = "<a href=\"http://www.flickr.com/photos/#{@@user_id}/#{photo.id}/in/set-#{@@set_id}/\">"
      res += "<img src=\"#{photo.url_t}\" title=\"#{photo.title}\" />"
      res += "<span class=\"label\">#{photo.title}</span></a>"
    end
  end
end

#Liquid::Template.register_tag('flickr_photo', Jekyll::FlickrPhoto)