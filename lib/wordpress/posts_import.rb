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
      image_links = images.collect { | image_object | image_object[ 1 ].value }

      image_links.each do | link |
        file = open( link )
        location = "#{ link.split( "/" )[ -1 ] }"
        IO.copy_stream( file, location )
        save_image_s3( location )
        uploaded_link = "https://s3.us-east-2.amazonaws.com/beb-backup/#{ location }"
        FileUtils.rm( location )
        content[ link ] = uploaded_link
      end

      content
    end

    def comments
      @doc.xpath( "wp:comment" ).collect do | comment |
        Comment.new( body: comment.text )
      end
    end

    def category
      @doc.xpath( "category" ).text
    end

    def save_image_s3( location )
      file = location
      bucket = 'beb-backup'
      name = File.basename( file )
      obj = AWS_RESOURCE.bucket( bucket ).object( name )
      uploaded_file = obj.upload_file( file )
    end

    def format_syntax_highlighter( text )
      text.gsub(/\[(\w+)\](.+?)\[\/\1\]/m) do |match|
        "\n```#{$1}#{$2}```\n"
      end
    end
  end
end
