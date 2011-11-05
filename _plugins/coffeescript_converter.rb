module Jekyll
  class CoffeeScriptConverter < Converter
    safe true
    priority :normal
    
    def setup
      return if @setup
      @coffeebin = "coffee" if Kernel.system("which coffee > /dev/null")
      unless @coffeebin then 
        STDERR.puts 'You are missing coffe.'
        raise FatalException.new("Missing program: coffee")
      end
      @setup = true
    end
    
    def matches(ext)
      ext =~ /coffee/i
    end

    def output_ext(ext)
      ".js"
    end

    def convert(content)
      begin
        setup
        cmd = [@coffeebin, '-s', '-c']
        result = IO.popen(cmd, "r+") do |f|
          f.write content
          f.close_write
          f.read
        end
      rescue StandardError => e
        puts "CoffeeScript error:" + e.message
      end
    end
  end
end
