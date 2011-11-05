module Jekyll
  class RstConverter < Converter
    safe true

    priority :low
    pygments_prefix ".. \n"
    pygments_suffix "\n"
    
    def setup
      return if @setup
      @rstbin = case
        when Kernel.system("which rst2html > /dev/null") then "rst2html"
        when Kernel.system("which rst2html.py > /dev/null") then "rst2html.py"
        else
          STDERR.puts 'You are missing docutils.'
          raise FatalException.new("Missing program: docutils")
      end
      @setup = true
    end
    
    def matches(ext)
      ext =~ /rst/i
    end 

    def output_ext(ext)
      ".html"
    end
    
    def cleanup(txt)
      
      txt = txt[/<div class="document">(.*)<\/div>/m, 1]
      cleanups = {/<span class="pre">(.*?)<\/span>/m => '\1',
                  /\ class="docutils literal"/ => "",
                  /\ class="literal-block"/ => "",
                  /<!--\ (<div\ class="highlight">.*?<\/div>) -->/m => '\1'}
      cleanups.each {|rx, repl| txt.gsub! rx, repl }
      txt
    end
    
    def prepare(content)
      content.gsub!(/\.\.\ *?\n.*?<pre>(.*?)<\/div>\n{2}/m){|match|
        match.gsub! "\n", "\n    "
      }
      content
    end

    def convert(content)
      prepare content
      setup
      cmd = [@rstbin, "--link-stylesheet"]
      result = IO.popen(cmd, "r+") do |f|
        f.write content
        f.close_write
        f.read
      end
      cleanup result
    end
  end
end