module WordPress
  class Data
    attr_reader :doc

    def initialize
      file = File.expand_path( "public/xml_backups/post-backups.xml" )
      file = File.open( file )
      @doc  = Nokogiri::XML( file.read().gsub("\u0004", "") )
    end

    def posts
      @doc.xpath( "//item[wp:post_type = 'post']" ).collect do | post |
        WordPress::Post.new( post )
      end
    end
  end

  class Post
    def initialize( doc )
      @doc = doc
    end

    def title
      @doc.xpath( "title" ).text
    end

    def slug
      @doc.xpath( "wp:post_name" ).text
    end

    def content
      content = @doc.xpath( "content:encoded" ).text
      content = format_syntax_highlighter( content )
      content.gsub( /[\n]{2,}+/, "\n\n" )
      images = Nokogiri::HTML( @doc.content ).css( "img" ).collect { | image | image.attributes.values }
      binding.pry
    end

    def comments
      @doc.xpath( "wp:comment" ).collect do | comment |
        Comment.new( body: comment.text )
      end
    end

    def category
      @doc.xpath( "category" ).text
    end

    def tags
      binding.pry
    end

    def format_syntax_highlighter( text )
      text.gsub(/\[(\w+)\](.+?)\[\/\1\]/m) do |match|
        "\n```#{$1}#{$2}```\n"
      end
    end
  end
end
